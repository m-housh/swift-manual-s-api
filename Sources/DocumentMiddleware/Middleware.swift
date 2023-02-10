import Dependencies
import Html
import Models
import XCTestDynamicOverlay

/// A middleware that returns html documents for the given routes.
///
public struct DocumentMiddleware {

  public var respond: (Route) async throws -> Node

  public init(
    respond: @escaping (Route) async throws -> Node
  ) {
    self.respond = respond
  }

  public func respond(route: Route) async throws -> Node {
    try await self.respond(route)
  }

  /// The routes handled by the documentation middleware.
  public enum Route {
    case home
    case documentation(ServerRoute.Documentation)
  }
}

extension DocumentMiddleware: TestDependencyKey {
  public static var testValue: DocumentMiddleware {
    return .init(respond: unimplemented("\(Self.self).respond"))
  }
}

extension DependencyValues {
  public var documentMiddleware: DocumentMiddleware {
    get { self[DocumentMiddleware.self] }
    set { self[DocumentMiddleware.self] = newValue }
  }
}
