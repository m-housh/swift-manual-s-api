import FirstPartyMocks
import Html
import Models
import SiteRouter

struct SizingLimitsHome: Renderable {

  let title: String = ServerRoute.Documentation.Route.Key.sizingLimits.text
  let route = ServerRoute.Api.Route.sizingLimits(.mock)
  let json = ServerRoute.Api.Route.SizingLimitRequest.mock
  var description: String {
    #"""
    This route is used to calculate the acceptable sizing limits for the given conditions.
    """#
  }

  func content() async throws -> Node {
    try await RouteView(
      json: json,
      route: route,
      title: title,
      description: description
    ).content()
  }

}
