import Dependencies
@_exported import DocumentMiddleware
import Html
import Models

extension DocumentMiddleware: DependencyKey {

  private static var home: Node { layout(Home()) }

  public static var liveValue: DocumentMiddleware {
    .init(render: { route in
      switch route {
      case .home:
        return home
      case let .documentation(documentRoute):
        return renderDocumentRoute(documentRoute)
      }
    })
  }
}
