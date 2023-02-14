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
        ("Capacity", "The heat pump capacity."),
        ("Design Temperature", "The winter outdoor design temperature."),
        ("Heat Loss", "The winter heat loss of the building."),
      ])
    }
  }

  func card(body: [(String, String)]) -> Node {
    let bodyNode = body.map({ (title, description) -> ChildOf<Tag.Ul> in
      .li(
        attributes: [.class("list-group-item pb-3 ps-2")],
        [
          Node.pre(attributes: [.class("text-secondary fs-5 mb-0")], .text(title)),
          Node.text(description),
        ]
      )
    })
    .reduce(into: Node.ul(attributes: [.class("list-group list-group-flush")])) {
      $0.append($1.rawValue)
    }

    return .div(
      attributes: [.class("card bg-success-subtle")],
      bodyNode
    )
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
