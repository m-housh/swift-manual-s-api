import Dependencies
@_exported import DocumentMiddleware
import Foundation
import Html
import Models

extension DocumentMiddleware: DependencyKey {

  public static var liveValue: DocumentMiddleware {
    return DocumentMiddleware { route in
      switch route {
      case .home:
        return try await layout(Home())
      case let .documentation(documentRoute):
        return try await renderDocumentRoute(documentRoute)
      }
    }
  }
}
