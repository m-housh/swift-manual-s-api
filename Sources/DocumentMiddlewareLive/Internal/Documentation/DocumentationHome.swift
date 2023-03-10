import Dependencies
import Html
import Models
import SiteRouter

struct DocumentHome: Renderable {

  @Dependency(\.siteRouter) var siteRouter

  let title: String = ServerRoute.Documentation.Key.home.text

  init() {}

  //  var content: Node {
  func content() async throws -> Node {
    container {
      row {
        [
          .h1("\(title)"),
          .hr(attributes: [.class(.border, .border(.success))]),
          _content,
          routes,
        ]
      }
    }
  }

  private var routes: Node {
    row {
      [
        .h2("Routes"),
        _links,
      ]
    }
  }

  private var _content: Node {
    row {
      .p(
        """
        Add some content here for the \(title) route.
        """)
    }
  }

  private var _links: Node {
    ServerRoute.Documentation.Route.Key.allCases
      .map {
        ChildOf<Tag.Ul>.li($0.link)
      }
      .reduce(into: Node.ul()) {
        $0.append($1.rawValue)
      }
  }

}

func renderDocumentRoute(_ documentRoute: ServerRoute.Documentation) async throws -> Node {
  switch documentRoute {
  case .home:
    return try await layout(DocumentHome(), navbar: Navbar(contents: Navbar.routesDropdown))
  case .api(.balancePoint):
    return try await layout(BalancePointHome())
  case .api(.derating):
    return try await layout(DeratingHome())
  case let .api(.interpolate(interpolateRoute)):
    return try await layout(renderInterpolateRoute(interpolateRoute))
  case .api(.requiredKW):
    return try await layout(RequiredKWHome())
  case .api(.sizingLimits):
    return try await layout(SizingLimitsHome())
  }
}
