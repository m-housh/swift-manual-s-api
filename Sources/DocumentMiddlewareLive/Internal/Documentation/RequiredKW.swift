import FirstPartyMocks
import Html
import Models

struct RequiredKWHome: Renderable {

  let title: String = ServerRoute.Documentation.Route.Key.requiredKW.text
  let route = ServerRoute.Api.Route.requiredKW(.mock)
  let json = ServerRoute.Api.Route.RequiredKWRequest.mock
  var description: String {
    #"""
    This route is used to calculate the required kilowatts for the given conditions.
    """#
  }
  let inputDescription = card(body: [
    ("capacityAtDesign", "The system capacity at the design temperature."),
    ("heatLoss", "The houses heat loss/load at the outdoor design temperature.")
  ])

  func content() async throws -> Node {
    try await RouteView(
      json: json,
      route: route,
      title: title,
      description: .text(description),
      inputDescription: inputDescription
    ).content()
  }

}
