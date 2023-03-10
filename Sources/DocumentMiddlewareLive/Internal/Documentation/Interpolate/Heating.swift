import FirstPartyMocks
import Html
import Models

func renderHeating(_ route: ServerRoute.Documentation.Route.Interpolation.Heating) -> any Renderable
{
  switch route {
  case .boiler:
    return BoilerView()
  case .electric:
    return ElectricView()
  case .furnace:
    return FurnaceView()
  case .heatPump:
    return HeatPumpView()
  }
}

private struct BoilerView: Renderable {

  let title: String = ServerRoute.Documentation.Route.Interpolation.Heating.boiler.text
  let route = ServerRoute.Api.Route.Interpolation.mock(route: .heating(route: .boiler(.mock)))
  let failingJson = ServerRoute.Api.Route.Interpolation.mock(route: .heating(route: .boiler(.zero)))
  let description = """
    This route is used to interpolate a boiler for the given conditons.
    """
  let inputDescription = card(body: [
    ("afue", "The boiler efficiency percentage."),
    ("elevation", "The project elevation."),
    ("houseLoad", "The project house load at the design conditons."),
    ("input", "The boiler's BTU input rating."),
  ])

  func content() async throws -> Node {
    try await RouteView(
      json: route,
      route: .interpolate(route),
      title: title,
      description: .text(description),
      inputDescription: inputDescription,
      failingJson: .interpolate(failingJson)
    ).content()
  }
}

private struct ElectricView: Renderable {

  let title: String = ServerRoute.Documentation.Route.Interpolation.Heating.electric.text
  let route = ServerRoute.Api.Route.Interpolation.mock(route: .heating(route: .electric(.mock)))
  let failingJson = ServerRoute.Api.Route.Interpolation.mock(
    route: .heating(route: .electric(.zero)))
  let description = """
    This route is used to interpolate an electric furnace for the given conditons.
    """
  let inputDescription = card(body: [
    (
      "heatPumpCapacity",
      """
        Optional heat pump capacity for the project.
        (This should be the final interpolated capacity at design conditions).
      """
    ),
    ("houseLoad", "The project house load at the design conditons."),
    ("inputKW", "The rated kilowatts of the electric furnace."),
  ])

  func content() async throws -> Node {
    try await RouteView(
      json: route,
      route: .interpolate(route),
      title: title,
      description: .text(description),
      inputDescription: inputDescription,
      failingJson: .interpolate(failingJson)
    ).content()
  }
}

private struct FurnaceView: Renderable {

  let title: String = ServerRoute.Documentation.Route.Interpolation.Heating.furnace.text
  let route = ServerRoute.Api.Route.Interpolation.mock(route: .heating(route: .furnace(.mock)))
  let failingJson = ServerRoute.Api.Route.Interpolation.mock(
    route: .heating(route: .furnace(.zero)))
  let description = """
    This route is used to interpolate a furnace for the given conditons.
    """

  let inputDescription = card(body: [
    ("afue", "The furnace efficiency percentage."),
    ("elevation", "The project elevation."),
    ("houseLoad", "The project house load at the design conditons."),
    ("input", "The furnace's BTU input rating."),
  ])

  func content() async throws -> Node {
    try await RouteView(
      json: route,
      route: .interpolate(route),
      title: title,
      description: .text(description),
      inputDescription: inputDescription,
      failingJson: .interpolate(failingJson)
    ).content()
  }
}

private struct HeatPumpView: Renderable {

  let title: String = ServerRoute.Documentation.Route.Interpolation.Heating.heatPump.text
  let route = ServerRoute.Api.Route.Interpolation.mock(route: .heating(route: .heatPump(.mock)))
  let failingJson = ServerRoute.Api.Route.Interpolation.mock(
    route: .heating(route: .heatPump(.zero)))
  let description = """
    This route is used to interpolate a heat pump for the given conditons.
    """

  let inputDescription = card(body: [
    ("capacity", "The manufacturer's capacity."),
    ("designInfo", "The design information for the project."),
    ("houseLoad", "The project house load at the design conditons."),
    ("systemType", "The system type for the project."),
  ])

  func content() async throws -> Node {
    try await RouteView(
      json: route,
      route: .interpolate(route),
      title: title,
      description: .text(description),
      inputDescription: inputDescription,
      failingJson: .interpolate(failingJson)
    ).content()
  }
}
