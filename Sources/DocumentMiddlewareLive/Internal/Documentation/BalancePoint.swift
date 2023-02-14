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

  var inputDescription: Node {
    container {
      card(body: [
        ("capacity", "The heat pump capacity."),
        ("designTemperature", "The winter outdoor design temperature."),
        ("heatLoss", "The winter heat loss of the building."),
      ])
    }
  }

  //  var content: Node {
  func content() async throws -> Node {
    try await RouteView(
      json: json.eraseToAnyEncodable(),
      route: route,
      title: title,
      description: .text(description),
      inputDescription: inputDescription
    ).content()
  }
}
