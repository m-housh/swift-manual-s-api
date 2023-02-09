import Dependencies
import Models
import RouteHandler
import ValidationMiddleware

public struct SiteMiddleware {

  @Dependency(\.routeHandler) var routeHandler
  @Dependency(\.validationMiddleware) var validations

  public func respond(route: ServerRoute) async throws -> AnyEncodable {
    try await validations.validate(route)
    return try await routeHandler.respond(route)
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
