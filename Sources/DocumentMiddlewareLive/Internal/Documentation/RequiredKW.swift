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

  func content() async throws -> Node {
    try await RouteView(
      json: json,
      route: route,
      title: title,
      description: description
    ).content()
  }

}
