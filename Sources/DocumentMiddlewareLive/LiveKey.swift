import ApiRouteMiddleware
import Dependencies
@_exported import DocumentMiddleware
import Foundation
import Html
import Models
import SiteRouter
import ValidationMiddleware

extension DocumentMiddleware: DependencyKey {

  public static var liveValue: DocumentMiddleware {
    return DocumentMiddleware { route in
      
      @Dependency(\.apiMiddleware) var apiMiddleware
      @Dependency(\.siteRouter) var siteRouter
      @Dependency(\.validationMiddleware) var validationMiddleware
      
      switch route {
      case .home:
        return try await layout(Home())
      case let .documentation(documentRoute):
        return try await renderDocumentRoute(documentRoute)
      }
    }
  }
}

