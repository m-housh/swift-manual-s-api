import Dependencies
import Html
import Models

public struct DocumentMiddleware {

  public func respond(route: ServerRoute) async throws -> Node {
    switch route {
    case .documentation(_):
      // Fix me.
      return layout(title: "Documentation", content: documentationHome())
    case .home:
      return layout(title: "Home", content: home())
    case .api:
      // This should be an error.
      return layout(title: "Home", content: home())

    }
  }
}

extension DocumentMiddleware: DependencyKey {
  public static var liveValue: DocumentMiddleware {
    return .init()
  }
}

extension DependencyValues {
  public var documentMiddleware: DocumentMiddleware {
    get { self[DocumentMiddleware.self] }
    set { self[DocumentMiddleware.self] = newValue }
  }
}
