import Dependencies
import Html
import Models
import SiteRouter

protocol Renderable {
  var title: String { get }
  var content: Node { get }
}

func link(for path: ServerRoute, text: String) -> Node {
  @Dependency(\.siteRouter) var siteRouter: SiteRouter

  return .a(attributes: [.href(siteRouter.path(for: path))], .text(text))
}
