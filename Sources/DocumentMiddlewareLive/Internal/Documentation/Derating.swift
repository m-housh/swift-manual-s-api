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
