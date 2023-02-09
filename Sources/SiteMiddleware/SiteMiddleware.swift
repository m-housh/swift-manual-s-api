import ApiRouteMiddleware
import Dependencies
import DocumentMiddleware
import Html
import Models
import ValidationMiddleware

public struct SiteMiddleware {

  @Dependency(\.documentMiddleware) var documentMiddleware
  @Dependency(\.apiMiddleware) var apiMiddleware
  @Dependency(\.validationMiddleware) var validations

  public func respond(route: ServerRoute) async throws -> Either<Node, AnyEncodable> {
    try await validations.validate(route)
    // TODO: make route handler only respond to api routes.
    switch route {
    case let .api(api):
      return try await .right(apiMiddleware.respond(api).eraseToAnyEncodable())
    case .home:
      return try await .left(documentMiddleware.respond(route: route))  // fix.
    }
  }
}

extension SiteMiddleware: DependencyKey {

  public static var liveValue: SiteMiddleware {
    .init()
  }

}

extension DependencyValues {

  public var siteMiddleware: SiteMiddleware {
    get { self[SiteMiddleware.self] }
    set { self[SiteMiddleware.self] = newValue }
  }
}

public enum Either<Left, Right> {
  case left(Left)
  case right(Right)

  public var left: Left? {
    switch self {
    case let .left(left):
      return left
    case .right:
      return nil
    }
  }

  public var right: Right? {
    switch self {
    case .left:
      return nil
    case let .right(right):
      return right
    }
  }
}
