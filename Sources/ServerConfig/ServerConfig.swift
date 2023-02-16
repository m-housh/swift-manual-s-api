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

  let baseURL = await configureBaseURL(app)

  await withDependencies(
    {
      $0.baseURL = baseURL
    },
    operation: {
      // configure the vapor middleware(s)
      await configureVaporMiddleware(app)

      // configure site router.
      await configureSiteRouter(app)
    })
}

// Configure the base url for the application / router.
private func configureBaseURL(_ app: Vapor.Application) async -> String {
  @Dependency(\.logger) var logger

  let baseURL: String =
    Environment.get("BASE_URL")
    ?? (app.environment == .production
      ? "http://localhost:8080"
      : "http://localhost:8080")

  logger.debug("Base URL: \(baseURL)")

  return baseURL
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

  let fileMiddleware = FileMiddleware(publicDirectory: app.directory.publicDirectory)
  app.middleware.use(fileMiddleware)
}

// Register the site router with the vapor application.
private func configureSiteRouter(_ app: Vapor.Application) async {

  @Dependency(\.baseURL) var baseURL: String
  @Dependency(\.logger) var logger: Logger
  @Dependency(\.siteRouter) var router: AnyParserPrinter<URLRequestData, ServerRoute>
  @Dependency(\.siteMiddleware) var siteMiddleware: SiteMiddleware

  logger.info("Bootstrapping site router.")

  app.mount(router.baseURL(baseURL), use: siteMiddleware.respond(request:route:))
}
