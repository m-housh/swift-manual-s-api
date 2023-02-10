import ApiRouteMiddlewareLive
import Dependencies
import HtmlVaporSupport  // remove and have site middleware handle this.
import Logging
import LoggingDependency
import Models
import SiteMiddleware
import SiteRouter
import ValidationMiddlewareLive
import Vapor
import VaporRouting

public func configure(_ app: Vapor.Application) async throws {

  await withDependencies {
    $0.apiMiddleware = .liveValue
    $0.logger = app.logger
    $0.siteRouter = .liveValue
    $0.validationMiddleware = .liveValue
  } operation: {

    // configure the vapor middleware(s)
    await configureVaporMiddleware(app)

    // configure site router.
    await configureSiteRouter(app)

  }

}

// Configure the vapor middleware.
private func configureVaporMiddleware(_ app: Vapor.Application) async {
  @Dependency(\.logger) var logger: Logger

  logger.info("Bootstrapping vapor middleware.")

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

// Register the site router with the vapor application.
private func configureSiteRouter(_ app: Vapor.Application) async {
  @Dependency(\.logger) var logger: Logger
  @Dependency(\.siteRouter) var router: SiteRouter

  logger.info("Bootstrapping site router.")
  app.mount(router, use: siteHandler(request:route:))
}

private func siteHandler(
  request: Request,
  route: ServerRoute
) async throws -> AsyncResponseEncodable {
  @Dependency(\.siteMiddleware) var siteMiddleware: SiteMiddleware
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
