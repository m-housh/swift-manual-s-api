import Dependencies
import Html
import Models
import SiteRouter

struct DocumentHome: Renderable {

  @Dependency(\.siteRouter) var siteRouter: SiteRouter

  let title: String = ServerRoute.Documentation.Key.home.text

  init() {}

  var content: Node {
    .div(
      attributes: [.class("container")],
      .div(
        attributes: [.class("row")],
        [
          .h1("\(title)"),
          _content,
          .h2("Routes"),
          _links,
        ])
    )
  }

  private var _content: Node {
    .p(
      """
      Add some content here for the \(title) route.
      """)
  }

  private var _links: Node {
    ServerRoute.Documentation.Route.Key.allCases
      .map {
        ChildOf<Tag.Ul>.li($0.link)
      }
      .reduce(into: Node.ul(.li(link(for: .home, text: "Home")))) {
        $0.append($1.rawValue)
      }
  }

}

func renderDocumentRoute(_ documentRoute: ServerRoute.Documentation) -> Node {
  switch documentRoute {
  case .home:
    return layout(DocumentHome())
  case .api(.balancePoint):
    return layout(BalancePointHome())
  case .api(.derating):
    return layout(DeratingHome())
  case let .api(.interpolate(interpolateRoute)):
    return renderInterpolateRoute(interpolateRoute)
  case .api(.requiredKW):
    return layout(RequiredKWHome())
  case .api(.sizingLimits):
    return layout(SizingLimitsHome())
  }
}
