import ApiRouteMiddleware
import Dependencies
import DocumentMiddleware
import Html
import HtmlVaporSupport
import Logging
import LoggingDependency
import Models
@_exported import SiteMiddleware
import ValidationMiddleware
import Vapor

extension SiteMiddleware: DependencyKey {

  public static var liveValue: SiteMiddleware {
    @Dependency(\.logger) var logger: Logger
    @Dependency(\.apiMiddleware) var apiMiddleware: ApiRouteMiddleware
    @Dependency(\.documentMiddleware) var documentMiddleware: DocumentMiddleware
    @Dependency(\.validationMiddleware) var validations: ValidationMiddleware

    return .init { request, route in

      try await validations.validate(route)

      switch route {

      case let .api(api):
        logger.debug(
          """
          Handling api route:
          Route: \(api.route)
          """)
        return try await apiMiddleware.respond(api).eraseToAnyEncodable()

      case let .documentation(documentationRoute):
        logger.debug(
          """
          Handling documentation route:
          Route: \(documentationRoute)
          """
        )
        return try await documentMiddleware.render(route: .documentation(documentationRoute))

      case .home:
        logger.debug("Handling home route.")
        return try await documentMiddleware.render(route: .home)

      case .appleTouchIcon, .appleTouchIconPrecomposed:
        return try await PublicFileMiddleware.respond(
          request: request, route: .images(file: "apple-touch-icon.png"))

      case .favicon:
        return try await PublicFileMiddleware.respond(request: request, route: .favicon)

      case .siteManifest:
        return try await request.fileio.streamFile(
          at: request.application.directory.publicDirectory.appending("site.manifest")
        )
        .encodeResponse(for: request)

      case let .public(publicRoute):
        logger.debug("Handling public route: \(publicRoute)")
        return try await PublicFileMiddleware.respond(request: request, route: publicRoute)
      }
    }
  }

  /// Handle a server route request, returning a response that `Vapor` can handle.
  ///
  /// - Parameters:
  ///   - route: The server route to respond to.
  public func respond(request: Request, route: ServerRoute) async throws -> AsyncResponseEncodable {
    try await self.respond(request, route)
  }
}

// MARK: - Helpers

/// Transform an any encodable type into an encodable type that vapor can use.
extension AnyEncodable: AsyncResponseEncodable {
  public func encodeResponse(for request: Vapor.Request) async throws -> Vapor.Response {
    let response = Response()
    response.headers.contentType = .json
    response.body = Response.Body(data: try JSONEncoder().encode(self))
    return response
  }
}

/// Transform an html node to type into an encodable type that vapor can use.
extension Node: AsyncResponseEncodable {
  public func encodeResponse(for request: Request) async throws -> Response {
    try await encodeResponse(for: request).get()
  }
}
