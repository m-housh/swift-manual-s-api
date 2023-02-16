import FirstPartyMocks
import Html
import Models
import SiteRouter

struct SizingLimitsHome: Renderable {

  let title: String = ServerRoute.Documentation.Route.Key.sizingLimits.text
  let route = ServerRoute.Api.Route.sizingLimits(.mock)
  let json = ServerRoute.Api.Route.SizingLimit.mock
  let failingJson = ServerRoute.Api.Route.sizingLimits(.zero)

  var description: String {
    #"""
    This route is used to calculate the acceptable sizing limits for the given conditions.
    """#
  }
  let inputDescription = card(body: [
    ("houseLoad", "The house load at the outdoor design conditions."),
    ("systemType", "The system type to calculate the sizing limits for."),
  ])

  func content() async throws -> Node {
    try await RouteView(
      json: json,
      route: route,
      title: title,
      description: .text(description),
      inputDescription: inputDescription,
      failingJson: failingJson
    ).content()
  }

}
