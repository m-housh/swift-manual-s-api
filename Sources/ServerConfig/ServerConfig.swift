import Dependencies
import Models
import RouteHandlerLive
import Router
import SiteMiddleware
import ValidationMiddlewareLive
import Vapor
import VaporRouting

public func configure(_ app: Application) throws {
  withDependencies { dependencies in
    dependencies.validationMiddleware = .liveValue
    dependencies.routeHandler = .liveValue
  } operation: {

    // configure the vapor middleware(s)
    configureVaporMiddleware(app)

    // configure the router.
    let router = ServerRouter(decoder: .init(), encoder: .init())

    // register the router and site handler.
    app.mount(router, use: siteHandler(request:route:))
  }

}

private func configureVaporMiddleware(_ app: Application) {
  let corsConfiguration = CORSMiddleware.Configuration(
    allowedOrigin: .all,
    allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
    allowedHeaders: [
      .accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent,
      .accessControlAllowOrigin,
    ]
  )
  let cors = CORSMiddleware(configuration: corsConfiguration)
  // cors middleware should come before default error middleware using `at: .beginning`
  app.middleware.use(cors, at: .beginning)
}

private func siteHandler(
  request: Request,
  route: ServerRoute
) async throws -> AsyncResponseEncodable {
  @Dependency(\.siteMiddleware) var siteMiddleware
  return try await siteMiddleware.respond(route: route)
}

extension AnyEncodable: AsyncResponseEncodable {
  public func encodeResponse(for request: Vapor.Request) async throws -> Vapor.Response {
    let response = Response()
    response.headers.contentType = .json
    response.body = Response.Body(data: try JSONEncoder().encode(self))
    return response
  }
}
