import Dependencies
@_exported import DocumentMiddleware
import Html
import Models

extension DocumentMiddleware: DependencyKey {

  public static var liveValue: DocumentMiddleware {
    .init(respond: { route in
      switch route {
      case .home:
        return layout(title: "Home", content: home())
      case .documentation(_):
        // TODO: fix to handle routes.
        return layout(title: "Documentation", content: documentationHome())
      }
    })
  }
}
