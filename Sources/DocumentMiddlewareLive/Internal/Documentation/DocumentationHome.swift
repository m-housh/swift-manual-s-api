import Dependencies
import Html
import Models
import SiteRouter

struct DocumentHome: Renderable {
  
  @Dependency(\.siteRouter) var siteRouter: SiteRouter
  
  let title: String = "Documentation"
  
  var content: Node {
    [
      .h1("\(title)"),
      _content,
      .h2("Routes"),
      _links,
    ]
  }
  
  private var _content: Node {
    .p("""
    Add some content here.
    """)
  }
  
  private var _links: Node {
    .ul(
      .li(link(for: .home, text: "Home")),
      .li(ServerRoute.Documentation.Route.Key.balancePoint.link),
      .li(ServerRoute.Documentation.Route.Key.derating.link),
      .li(ServerRoute.Documentation.Route.Key.interpolate.link), // fix
      .li(ServerRoute.Documentation.Route.Key.requiredKW.link),
      .li(ServerRoute.Documentation.Route.Key.sizingLimits.link)
    )
  }
  
  private var allCases: [ServerRoute] {
    [ServerRoute.home]
  }
  
}

extension ServerRoute.Documentation.Route.Key {
  
  static var routes: [(ServerRoute, String)] {
    allCases.map { ($0.route, $0.title) }
  }
  
  var link: Node {
    DocumentMiddlewareLive.link(for: self.route, text: self.title)
  }
  
  var route: ServerRoute {
    switch self {
    case .balancePoint:
      return .documentation(.api(.balancePoint))
    case .derating:
      return .documentation(.api(.derating))
    case .interpolate:
      // TODO: Fix me
      return .documentation(.home)
    case .requiredKW:
      return .documentation(.api(.requiredKW))
    case .sizingLimits:
      return .documentation(.api(.sizingLimits))
    }
  }
  
  var title: String {
    switch self {
    case .balancePoint:
      return "Balance Point"
    case .derating, .interpolate:
      return rawValue.capitalized
    case .requiredKW:
      return "Required KWh"
    case .sizingLimits:
      return "Sizing Limits"
    }
  }
  
}
