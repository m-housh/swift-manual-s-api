import Dependencies
import Html
import Models

/// Handle a server route, responding with either an html node or an encodable response.
///
public struct SiteMiddleware {

  /// Handle a server route, responding with either an html node or an encodable response.
  ///
  public var respond: (ServerRoute) async throws -> Either<Node, AnyEncodable>

  public init(
    respond: @escaping (ServerRoute) async throws -> Either<Node, AnyEncodable>
  ) {
    self.respond = respond
  }

}

extension SiteMiddleware: TestDependencyKey {

  public static var testValue: SiteMiddleware {
    .init(respond: unimplemented("\(Self.self).respond"))
  }

}

extension DependencyValues {

  public var siteMiddleware: SiteMiddleware {
    get { self[SiteMiddleware.self] }
    set { self[SiteMiddleware.self] = newValue }
  }
}

/// A helper type that holds  onto either a left or right value.
///
public enum Either<Left, Right> {
  case left(Left)
  case right(Right)

  /// Access the left value.
  public var left: Left? {
    switch self {
    case let .left(left):
      return left
    case .right:
      return nil
    }
  }

  /// Access the right value.
  public var right: Right? {
    switch self {
    case .left:
      return nil
    case let .right(right):
      return right
    }
  }
}
