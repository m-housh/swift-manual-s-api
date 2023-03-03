import ApiRouteMiddlewareLive
import Dependencies
import DocumentMiddlewareLive
import Logging
import LoggingDependency
import Models
import ServerEnvironment
import SiteMiddlewareLive
import SiteRouter
import ValidationMiddlewareLive
import Vapor
import VaporRouting

/// Configure the vapor application with the dependencies, middleware, routes, etc.
///
/// - Parameters:
///    - app: The vapor application to configure.
public func bootstrap(_ app: Vapor.Application) async throws {

  let apiMiddleware = ApiRouteMiddleware.liveValue
  let serverEnvironment = configureServerEnvironment(app)
  let siteRouter = SiteRouterKey.liveValue.eraseToAnyParserPrinter()
  let validationMiddleware = ValidationMiddleware.liveValue
  configureVaporMiddleware(app)

  let documentMiddleware = configureDocumentMiddleware(
    apiMiddleware: apiMiddleware,
    serverEnvironment: serverEnvironment,
    siteRouter: siteRouter,
    validationMiddleware: validationMiddleware
  )
  
  let siteHandler = siteHandler(
    apiMiddleware: apiMiddleware,
    documentMiddleware: documentMiddleware,
    serverEnvironment: serverEnvironment,
    siteRouter: siteRouter,
    validationMiddleware: validationMiddleware
  )
  app.mount(siteRouter, use: siteHandler)
}

// Configure the server environment for the application / router.
private func configureServerEnvironment(_ app: Vapor.Application) -> ServerEnvironment {
  @Dependency(\.logger) var logger

  var environment = ServerEnvironment.liveValue
  switch app.environment {
  case .production:
    environment.baseUrl = URL(string: "https://hvacmath.com")!
  default:
    break
  }
  
  logger.debug("Base URL: \(environment.baseUrl)")

  return environment
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
//private func configureSiteRouter(
//  _ app: Vapor.Application,
//  baseUrl: String
//) -> AnyParserPrinter<URLRequestData, ServerRoute> {
//
//  @Dependency(\.logger) var logger: Logger
//
//  logger.info("Bootstrapping site router.")
//
//
//}

private func configureDocumentMiddleware(
  apiMiddleware: ApiRouteMiddleware,
  serverEnvironment: ServerEnvironment,
  siteRouter: AnyParserPrinter<URLRequestData, ServerRoute>,
  validationMiddleware: ValidationMiddleware
) -> DocumentMiddleware {
  withDependencies {
    $0.apiMiddleware = apiMiddleware
    $0.serverEnvironment = serverEnvironment
    $0.siteRouter = siteRouter
    $0.validationMiddleware = validationMiddleware
  } operation: {
    return .liveValue
  }
}

private func siteHandler(
  apiMiddleware: ApiRouteMiddleware,
  documentMiddleware: DocumentMiddleware,
  serverEnvironment: ServerEnvironment,
  siteRouter: AnyParserPrinter<URLRequestData, ServerRoute>,
  validationMiddleware: ValidationMiddleware
) -> (Request, ServerRoute) async throws -> AsyncResponseEncodable {
  return { request, route in
    try await withDependencies { dependencies in
      dependencies.serverEnvironment = serverEnvironment
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
