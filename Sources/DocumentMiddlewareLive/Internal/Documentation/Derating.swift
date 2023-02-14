import Dependencies
import FirstPartyMocks
import Html
import Models
import SiteRouter

struct DeratingHome: Renderable {

  let title: String = ServerRoute.Documentation.Route.Key.derating.text
  let route = ServerRoute.Api.Route.derating(.mock)
  let json = ServerRoute.Api.Route.DeratingRequest.mock
  var description: String {
    #"""
    This route is used to calculate the elevation deratings for the given conditions.
    """#
  }
  let inputDescription = card(body: [
    ("elevation", "The project elevation."),
    ("systemType", "The system type to calculate the deratings for.")
  ])

  //  var content: Node {
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
