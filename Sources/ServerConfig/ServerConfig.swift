import Dependencies
import Logging
import LoggingDependency
import Models
import SiteMiddlewareLive
import SiteRouter
import Vapor
import VaporRouting

/// Configure the vapor application with the dependencies, middleware, routes, etc.
///
/// - Parameters:
///    - app: The vapor application to configure.
public func configure(_ app: Vapor.Application) async throws {

  await withDependencies(
    {
      // This doesn't seem to really work.
      $0.baseURL =
        app.environment == .production
        ? "http://localhost:8080"
        : "http://localhost:8080"
    },
    operation: {
      // configure the vapor middleware(s)
      await configureVaporMiddleware(app)

      // configure site router.
      await configureSiteRouter(app)
    })
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
  @Dependency(\.siteRouter) var router: AnyParserPrinter<URLRequestData, ServerRoute>
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
