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

    return .init { route in

      try await validations.validate(route)

      switch route {
      case let .api(api):
        logger.debug(
          """
          Handling api route:
          Route: \(api.route)
          """)
        return try await .right(apiMiddleware.respond(api).eraseToAnyEncodable())
      case let .documentation(documentationRoute):
        logger.debug(
          """
          Handling documentation route:
          Route: \(documentationRoute)
          """
        )
        return try await .left(
          documentMiddleware.respond(route: .documentation(documentationRoute)))
      case .home:
        logger.debug("Handling home route.")
        return try await .left(documentMiddleware.respond(route: .home))
      }
    }
  }

  /// Handle a server route request, returning a response that `Vapor` can handle.
  ///
  /// - Parameters:
  ///   - route: The server route to respond to.
  public func respond(route: ServerRoute) async throws -> AsyncResponseEncodable {
    try await self.respond(route)
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

/// Transform an either to an encodable type that vapor can use.
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
