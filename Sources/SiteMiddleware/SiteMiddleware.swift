import ApiRouteMiddleware
import Dependencies
import DocumentMiddleware
import Html
import Logging
import LoggingDependency
import Models
import ValidationMiddleware

public struct SiteMiddleware {

  @Dependency(\.logger) var logger
  @Dependency(\.apiMiddleware) var apiMiddleware
  @Dependency(\.documentMiddleware) var documentMiddleware
  @Dependency(\.validationMiddleware) var validations

  public func respond(route: ServerRoute) async throws -> Either<Node, AnyEncodable> {
    try await validations.validate(route)
    switch route {
    case let .api(api):
      logger.debug(
        """
        Handling api route:
        Route: \(api.route)
        """)
      return try await .right(apiMiddleware.respond(api).eraseToAnyEncodable())
    case .documentation(_):
      // fix
      return try await .left(documentMiddleware.respond(route: route))
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
