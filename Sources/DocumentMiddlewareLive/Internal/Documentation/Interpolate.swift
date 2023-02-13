import Dependencies
import Html
import Models
import SiteRouter

struct InterpolateHome: Renderable {

  @Dependency(\.siteRouter) var siteRouter

  let title: String = ServerRoute.Documentation.Route.Key.interpolate.text

  //  var content: Node {
  func content() async throws -> Node {
    .div(
      attributes: [.class("container")],
      .div(
        attributes: [.class("row")],
        [
          .h1("\(title)"),
          _content,
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
    .ul(
      .li(link(for: .documentation(.home), text: "Documentation"))
    )
  }

}

struct OneWayIndoorRoute: Renderable {
  let title: String = ServerRoute.Documentation.Route.Interpolation.Cooling.oneWayIndoor.text
  let route = ServerRoute.Api.Route.interpolate(.cooling(.oneWayIndoor(.indoorMock)))
  let json = ServerRoute.Api.Route.InterpolationRequest.Cooling.OneWayRequest.indoorMock

  var description: Node {
    row {
      [
        .p(
          "This route is used for one way interpolation of manufacturer's capacities at indoor design conditions."
        ),
        .br,
        .br,
        .h6(
          attributes: [],
          "Example: My summer outdoor design is 95° dry-bulb and my indoor design is 63° wet-bulb"
        ),
        .ul(
          attributes: [.class("ms-5")],
          .li(
            .text("The manufacturer's published outdoor data is equal to the design conditions.")),
          .li(
            .text(
              "The manufacturer's published indoor data is 67° and 62° wet-bulb, so interpolation is needed to calculate the capacity at 63° wet-bulb."
            ))
        ),
      ]
    }
  }

  func content() async throws -> Node {
    try await RouteDocument(
      json: json,
      route: route,
      title: title,
      description: description
    ).content()
  }
}

private func renderCooling(_ route: ServerRoute.Documentation.Route.Interpolation.Cooling)
  async throws -> Node
{
  switch route {
  case .oneWayIndoor:
    return try await layout(OneWayIndoorRoute())
  case .oneWayOutdoor:
    return try await layout(InterpolateHome())  // fix
  case .noInterpolation:
    return try await layout(InterpolateHome())  // fix
  case .twoWay:
    return try await layout(InterpolateHome())  // fix
  }
}

func renderInterpolateRoute(_ route: ServerRoute.Documentation.Route.Interpolation) async throws
  -> Node
{
  switch route {
  case .home:
    return try await layout(InterpolateHome())
  case let .cooling(cooling):
    return try await renderCooling(cooling)
  case .heating(_):
    return try await layout(InterpolateHome())  // fix.
  }
}
