import Dependencies
import FirstPartyMocks
import Foundation
import JsonDependency
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
      return ServerRoute.Api.Route.Interpolation.Single.Route.Heating.Boiler.mock
    case .electric:
      return ServerRoute.Api.Route.Interpolation.Single.Route.Heating.Electric.mock
    case .furnace:
      return ServerRoute.Api.Route.Interpolation.Single.Route.Heating.Furnace.mock
    case .heatPump:
      return ServerRoute.Api.Route.Interpolation.Single.Route.Heating.HeatPump.mock
    case .noInterpolation:
      return ServerRoute.Api.Route.Interpolation.Single.Route.Cooling.NoInterpolation
        .mock
    case .oneWayIndoor:
      return ServerRoute.Api.Route.Interpolation.Single.Route.Cooling.OneWay.indoorMock
    case .oneWayOutdoor:
      return ServerRoute.Api.Route.Interpolation.Single.Route.Cooling.OneWay
        .outdoorMock
    case .project:
      return Project.mock
    case .twoWay:
      return ServerRoute.Api.Route.Interpolation.Single.Route.Cooling.TwoWay.mock
    }
  }

}

extension Template.EmbeddableKey {

  func embedInRoute(_ data: Data) throws
    -> ServerRoute.Api.Route.Interpolation.Single.Route
  {
    @Dependency(\.json.jsonDecoder) var decoder
    let route: ServerRoute.Api.Route.Interpolation.Single.Route
    switch self {
    case .boiler:
      let type = ServerRoute.Api.Route.Interpolation.Single.Route.Heating.Boiler.self
      route = try .heating(route: .boiler(decoder.decode(type, from: data)))
    case .electric:
      let type = ServerRoute.Api.Route.Interpolation.Single.Route.Heating.Electric.self
      route = try .heating(route: .electric(decoder.decode(type, from: data)))
    case .furnace:
      let type = ServerRoute.Api.Route.Interpolation.Single.Route.Heating.Furnace.self
      route = try .heating(route: .furnace(decoder.decode(type, from: data)))
    case .heatPump:
      let type = ServerRoute.Api.Route.Interpolation.Single.Route.Heating.HeatPump.self
      route = try .heating(route: .heatPump(decoder.decode(type, from: data)))
    case .noInterpolation:
      let type = ServerRoute.Api.Route.Interpolation.Single.Route.Cooling
        .NoInterpolation.self
      route = try .cooling(route: .noInterpolation(decoder.decode(type, from: data)))
    case .oneWayIndoor:
      let type = ServerRoute.Api.Route.Interpolation.Single.Route.Cooling.OneWay.self
      route = try .cooling(
        route: .oneWayIndoor(
          .init(decoder.decode(type, from: data)))
      )
    case .oneWayOutdoor:
      let type = ServerRoute.Api.Route.Interpolation.Single.Route.Cooling.OneWay.self
      route = try .cooling(
        route: .oneWayOutdoor(
          .init(decoder.decode(type, from: data)))
      )
    case .twoWay:
      let type = ServerRoute.Api.Route.Interpolation.Single.Route.Cooling.TwoWay.self
      route = try .cooling(route: .twoWay(decoder.decode(type, from: data)))
    }
    return route
  }

  func embed(
    data: Data,
    in baseInterpolation: Template.BaseInterpolation
  ) throws -> ServerRoute.Api.Route.Interpolation {
    let route = try embedInRoute(data)
    return .init(
      designInfo: baseInterpolation.designInfo,
      houseLoad: baseInterpolation.houseLoad,
      systemType: baseInterpolation.systemType,
      route: route
    )
  }
}
