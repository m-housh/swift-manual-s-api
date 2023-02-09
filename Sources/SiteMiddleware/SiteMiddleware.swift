import ApiRouteMiddleware
import Dependencies
import DocumentMiddleware
import Models
import ValidationMiddleware

public struct SiteMiddleware {

  @Dependency(\.documentMiddleware) var documentMiddleware
  @Dependency(\.apiMiddleware) var apiMiddleware
  @Dependency(\.validationMiddleware) var validations

  public func respond(route: ServerRoute) async throws -> AnyEncodable {
    try await validations.validate(route)
    // TODO: make route handler only respond to api routes.
    switch route {
    case let .api(api):
      return try await apiMiddleware.respond(api).eraseToAnyEncodable()
    case .home:
      return "\(route)".eraseToAnyEncodable()  // fix.
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
