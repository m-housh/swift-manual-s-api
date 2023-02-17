import ApiRouteMiddlewareLive
import Dependencies
import DocumentMiddlewareLive
import Logging
import LoggingDependency
import Models
import SiteMiddlewareLive
import SiteRouter
import ValidationMiddlewareLive
import Vapor
import VaporRouting

/// Configure the vapor application with the dependencies, middleware, routes, etc.
///
/// - Parameters:
///    - app: The vapor application to configure.
public func configure(_ app: Vapor.Application) async throws {

  let baseURL = await configureBaseURL(app)
  let apiMiddleware = ApiRouteMiddleware.liveValue
  let validationMiddleware = ValidationMiddleware.liveValue
  configureVaporMiddleware(app)
  
  let siteRouter = configureSiteRouter(app, baseUrl: baseURL)
  let documentMiddleware = configureDocumentMiddleware(
    apiMiddleware: apiMiddleware,
    siteRouter: siteRouter,
    validationMiddleware: validationMiddleware
  )
  let siteHandler = siteHandler(
    baseURL: baseURL,
    siteRouter: siteRouter,
    apiMiddleware: apiMiddleware,
    validationMiddleware: validationMiddleware,
    documentMiddleware: documentMiddleware
  )
  app.mount(siteRouter, use: siteHandler)
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
private func configureVaporMiddleware(_ app: Vapor.Application) {
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
private func configureSiteRouter(
  _ app: Vapor.Application,
  baseUrl: String
) -> AnyParserPrinter<URLRequestData, ServerRoute> {

  @Dependency(\.logger) var logger: Logger
  
  logger.info("Bootstrapping site router.")
  return withDependencies {
    $0.baseURL = baseUrl
  } operation: {
    return SiteRouterKey.liveValue
  }
}

private func configureDocumentMiddleware(
  apiMiddleware: ApiRouteMiddleware,
  siteRouter: AnyParserPrinter<URLRequestData, ServerRoute>,
  validationMiddleware: ValidationMiddleware
) -> DocumentMiddleware {
  withDependencies {
    $0.apiMiddleware = apiMiddleware
    $0.siteRouter = siteRouter
    $0.validationMiddleware = validationMiddleware
  } operation: {
    return .liveValue
  }
}

private func siteHandler(
  baseURL: String,
  siteRouter: AnyParserPrinter<URLRequestData, ServerRoute>,
  apiMiddleware: ApiRouteMiddleware,
  validationMiddleware: ValidationMiddleware,
  documentMiddleware: DocumentMiddleware
) -> (Request, ServerRoute) async throws -> AsyncResponseEncodable {
  return { request, route in
    try await withDependencies { dependencies in
      dependencies.baseURL = baseURL
      dependencies.siteRouter = siteRouter
      dependencies.apiMiddleware = apiMiddleware
      dependencies.validationMiddleware = validationMiddleware
      dependencies.documentMiddleware = documentMiddleware
    } operation: {
      let siteMiddleware = SiteMiddleware.liveValue
      return try await siteMiddleware.respond(request: request, route: route)
    }
  }

}
