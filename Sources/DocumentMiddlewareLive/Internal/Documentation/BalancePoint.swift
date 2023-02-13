import Dependencies
import FirstPartyMocks
import Html
import Models
import SiteRouter

struct BalancePointHome: Renderable {

  let title: String = ServerRoute.Documentation.Route.Key.balancePoint.text
  let route = ServerRoute.Api.Route.balancePoint(.thermal(.mock))
  let json = ServerRoute.Api.Route.BalancePointRequest.Thermal.mock
  var description: String {
    #"""
    This route is used to calculate the thermal balance point for the given conditions.
    """#
  }

  //  var content: Node {
  func content() async throws -> Node {
    try await RouteDocument(
      json: json,
      route: route,
      title: title,
      description: description
    ).content()
  }
}
