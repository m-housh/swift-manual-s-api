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
  let route = ServerRoute.Api.Route.interpolate(.heating(.boiler(.mock)))
  let json = ServerRoute.Api.Route.InterpolationRequest.Heating.BoilerRequest.mock
  let description = """
    This route is used to interpolate a boiler for the given conditons.
    """
  let inputDescription = card(body: [
    ("afue", "The boiler efficiency percentage."),
    ("altitudeDeratings", "The boiler efficiency percentage."),
  ])

  func content() async throws -> Node {
    try await RouteView(
      json: json,
      route: route,
      title: title,
      description: .text(description),
      inputDescription: .text("")  // FIXME

    ).content()
  }
}

private struct ElectricView: Renderable {

  let title: String = ServerRoute.Documentation.Route.Interpolation.Heating.electric.text
  let route = ServerRoute.Api.Route.interpolate(.heating(.electric(.mock)))
  let json = ServerRoute.Api.Route.InterpolationRequest.Heating.ElectricRequest.mock
  let description = """
    This route is used to interpolate an electric furnace for the given conditons.
    """

  func content() async throws -> Node {
    try await RouteView(
      json: json,
      route: route,
      title: title,
      description: .text(description),
      inputDescription: .text("")  // FIXME
    ).content()
  }
}

private struct FurnaceView: Renderable {

  let title: String = ServerRoute.Documentation.Route.Interpolation.Heating.furnace.text
  let route = ServerRoute.Api.Route.interpolate(.heating(.furnace(.mock)))
  let json = ServerRoute.Api.Route.InterpolationRequest.Heating.FurnaceRequest.mock
  let description = """
    This route is used to interpolate a furnace for the given conditons.
    """

  func content() async throws -> Node {
    try await RouteView(
      json: json,
      route: route,
      title: title,
      description: .text(description),
      inputDescription: .text("")  // FIXME
    ).content()
  }
}

private struct HeatPumpView: Renderable {

  let title: String = ServerRoute.Documentation.Route.Interpolation.Heating.heatPump.text
  let route = ServerRoute.Api.Route.interpolate(.heating(.heatPump(.mock)))
  let json = ServerRoute.Api.Route.InterpolationRequest.Heating.HeatPumpRequest.mock
  let description = """
    This route is used to interpolate a heat pump for the given conditons.
    """

  func content() async throws -> Node {
    try await RouteView(
      json: json,
      route: route,
      title: title,
      description: .text(description),
      inputDescription: .text("")  // FIXME
    ).content()
  }
}
