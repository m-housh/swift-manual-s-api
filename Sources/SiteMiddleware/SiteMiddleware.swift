import Dependencies
import Html
import Models
import Vapor

/// Handle a server route, responding with either an html node or an encodable response.
///
public struct SiteMiddleware {

  /// Handle a server route, responding with either an html node or an encodable response.
  ///
  public var respond: (Request, ServerRoute) async throws -> AsyncResponseEncodable

  public init(
    respond: @escaping (Request, ServerRoute) async throws -> AsyncResponseEncodable
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
