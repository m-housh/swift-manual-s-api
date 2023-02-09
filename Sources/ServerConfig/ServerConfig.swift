import ApiRouteMiddlewareLive
import Dependencies
import DocumentMiddleware  // remove and have site middleware handle this.
import HtmlVaporSupport  // remove and have site middleware handle this.
import Models
import SiteMiddleware
import SiteRouter
import ValidationMiddlewareLive
import Vapor
import VaporRouting

public func configure(_ app: Vapor.Application) throws {

  withDependencies { dependencies in
    dependencies.validationMiddleware = .liveValue
    dependencies.apiMiddleware = .liveValue
  } operation: {

    // configure the vapor middleware(s)
    configureVaporMiddleware(app)

    // register the router and site handler.
    let router = SiteRouter.liveValue
    app.mount(router, use: siteHandler(request:route:))
  }

}

private func configureVaporMiddleware(_ app: Vapor.Application) {
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

extension Node: AsyncResponseEncodable {
  public func encodeResponse(for request: Request) async throws -> Response {
    try await encodeResponse(for: request).get()
  }
}

extension Either: AsyncResponseEncodable
where Left: AsyncResponseEncodable, Right: AsyncResponseEncodable {

  public func encodeResponse(for request: Request) async throws -> Response {
    switch self {
    case let .left(left):
      return try await left.encodeResponse(for: request)
    case let .right(right):
      return try await right.encodeResponse(for: request)
    }
  }
}
