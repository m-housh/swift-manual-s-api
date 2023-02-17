import ApiRouteMiddleware
import Dependencies
import Html
import Models
import SiteRouter
import ValidationMiddleware
import XCTestDynamicOverlay

/// A middleware that returns html documents for the given routes.
///
public struct DocumentMiddleware {
  
  public var render: (Route) async throws -> Node

  @inlinable
  public init(
    render: @escaping (Route) async throws -> Node
  ) {
    self.render = render
  }

  @inlinable
  public func render(route: Route) async throws -> Node {
    try await self.render(route)
  }

  /// The routes handled by the documentation middleware.
  public enum Route {
    case home
    case documentation(ServerRoute.Documentation)
  }
}

extension DocumentMiddleware: TestDependencyKey {
  public static var testValue: DocumentMiddleware {
    return .init(render: unimplemented("\(Self.self).respond"))
  }
}

extension DependencyValues {
  public var documentMiddleware: DocumentMiddleware {
    get { self[DocumentMiddleware.self] }
    set { self[DocumentMiddleware.self] = newValue }
  }
}
