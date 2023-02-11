import Dependencies
@_exported import DocumentMiddleware
import Html
import Models

extension DocumentMiddleware: DependencyKey {

  public static var liveValue: DocumentMiddleware {
    .init(render: { route in
      switch route {
      case .home:
        return layout(title: "Home", content: home())
      case let .documentation(documentRoute):
        return renderDocumentRoute(documentRoute)
      }
    })
  }
}
