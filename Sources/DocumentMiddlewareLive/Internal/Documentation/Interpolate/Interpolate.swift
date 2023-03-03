import Dependencies
import Html
import Models
import SiteRouter

func renderInterpolateRoute(_ route: ServerRoute.Documentation.Route.Interpolation) async throws
  -> any Renderable
{
  switch route {
  case .home:
    return InterpolateHome()
  case let .cooling(cooling):
    return renderCooling(cooling)
  case let .heating(heating):
    return renderHeating(heating)
  }
}

#warning("Add project routes.")
struct InterpolateHome: Renderable {

  @Dependency(\.siteRouter) var siteRouter

  let title: String = ServerRoute.Documentation.Route.Key.interpolate.text

  //  var content: Node {
  func content() async throws -> Node {
    container {
      [
        titleRow(title: title, content: .hr(attributes: [.class(.border, .border(.success))])),
        _content,
        linkRow(title: "Cooling Routes", content: _coolingLinks),
        linkRow(title: "Heating Routes", content: _heatingLinks),
      ]
    }
  }

  private var _content: Node {
    .p(
      """
      Add some content here for the \(title) route.
      """)
  }

  private func titleRow(title: String, content: Node) -> Node {
    row {
      [
        .h1(.text(title)),
        content,
      ]
    }
  }

  private func linkRow(title: String, content: Node) -> Node {
    DocumentMiddlewareLive.row {
      [
        .h3(.text(title)),
        content,
      ]
    }
  }
  private var _coolingLinks: Node {
    .ul(
      .li(link(for: ServerRoute.Documentation.Route.Interpolation.Cooling.noInterpolation)),
      .li(link(for: ServerRoute.Documentation.Route.Interpolation.Cooling.oneWayIndoor)),
      .li(link(for: ServerRoute.Documentation.Route.Interpolation.Cooling.oneWayOutdoor)),
      .li(link(for: ServerRoute.Documentation.Route.Interpolation.Cooling.twoWay))
    )
  }

  private var _heatingLinks: Node {
    .ul(
      .li(link(for: ServerRoute.Documentation.Route.Interpolation.Heating.boiler)),
      .li(link(for: ServerRoute.Documentation.Route.Interpolation.Heating.electric)),
      .li(link(for: ServerRoute.Documentation.Route.Interpolation.Heating.furnace)),
      .li(link(for: ServerRoute.Documentation.Route.Interpolation.Heating.heatPump))
    )
  }

  //  private var _links: Node {
  //    .ul(
  //      .li(link(for: .documentation(.home), text: "Documentation"))
  //    )
  //  }

}
