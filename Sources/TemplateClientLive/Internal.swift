import FirstPartyMocks
import Foundation
import Models

extension Template.PathKey {

  init?(keyPath: KeyPath<Template.Path, String>, paths: Template.Path) {
    guard
      let path = Self.allCases.first(where: {
        paths[keyPath: $0.templateKeyPath] == paths[keyPath: keyPath]
      })
    else {
      return nil
    }
    self = path
  }

  public var mock: any Encodable {
    switch self {
    case .baseInterpolation:
      return Template.BaseInterpolation.mock
    case .boiler:
      return ServerRoute.Api.Route.Interpolation.Route.Heating.Boiler.mock
    case .electric:
      return ServerRoute.Api.Route.Interpolation.Route.Heating.Electric.mock
    case .furnace:
      return ServerRoute.Api.Route.Interpolation.Route.Heating.Furnace.mock
    case .heatPump:
      return ServerRoute.Api.Route.Interpolation.Route.Heating.HeatPump.mock
    case .keyed:
      return [ServerRoute.Api.Route.Interpolation.Route.Keyed].mocks
    case .noInterpolation:
      return ServerRoute.Api.Route.Interpolation.Route.Cooling.NoInterpolation.mock
    case .oneWayIndoor:
      return ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay.indoorMock
    case .oneWayOutdoor:
      return ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay.outdoorMock
    case .project:
      return Template.Project()
    case .twoWay:
      return ServerRoute.Api.Route.Interpolation.Route.Cooling.TwoWay.mock
    }
  }

}

extension Template.EmbeddableKey {

  func embedInRoute(_ data: Data) throws -> ServerRoute.Api.Route.Interpolation.Route {
    let route: ServerRoute.Api.Route.Interpolation.Route
    let decoder = JSONDecoder()
    switch self {
    case .boiler:
      let type = ServerRoute.Api.Route.Interpolation.Route.Heating.Boiler.self
      route = try .heating(route: .boiler(decoder.decode(type, from: data)))
    case .electric:
      let type = ServerRoute.Api.Route.Interpolation.Route.Heating.Electric.self
      route = try .heating(route: .electric(decoder.decode(type, from: data)))
    case .furnace:
      let type = ServerRoute.Api.Route.Interpolation.Route.Heating.Furnace.self
      route = try .heating(route: .furnace(decoder.decode(type, from: data)))
    case .heatPump:
      let type = ServerRoute.Api.Route.Interpolation.Route.Heating.HeatPump.self
      route = try .heating(route: .heatPump(decoder.decode(type, from: data)))
    case .keyed:
      let type = [ServerRoute.Api.Route.Interpolation.Route.Keyed].self
      route = try .keyed(decoder.decode(type, from: data))
    case .noInterpolation:
      let type = ServerRoute.Api.Route.Interpolation.Route.Cooling.NoInterpolation.self
      route = try .cooling(route: .noInterpolation(decoder.decode(type, from: data)))
    case .oneWayIndoor:
      let type = ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay.self
      route = try .cooling(
        route: .oneWayIndoor(
          .init(decoder.decode(type, from: data)))
      )
    case .oneWayOutdoor:
      let type = ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay.self
      route = try .cooling(
        route: .oneWayIndoor(
          .init(decoder.decode(type, from: data)))
      )
    case .twoWay:
      let type = ServerRoute.Api.Route.Interpolation.Route.Cooling.TwoWay.self
      route = try .cooling(route: .twoWay(decoder.decode(type, from: data)))
    }
    return route
  }

  func embed(
    data: Data,
    in baseInterpolation: Template.BaseInterpolation
  ) throws -> Interpolation {
    let route = try embedInRoute(data)

    var systemType: SystemType?
    if case .keyed = route {
      systemType = nil
    } else {
      systemType = baseInterpolation.systemType
    }

    return .init(
      designInfo: baseInterpolation.designInfo,
      houseLoad: baseInterpolation.houseLoad,
      systemType: systemType,
      route: route
    )
  }
}
