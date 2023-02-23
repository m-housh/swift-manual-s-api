import ArgumentParser
import FirstPartyMocks
import Foundation
import Models

enum InterpolationName: String, EnumerableFlag {
  case boiler
  case electric
  case furnace
  case heatPump
  case noInterpolation
  case oneWayIndoor
  case oneWayOutdoor
  case twoWay
  
  var defaultOutputPath: String {
    "./\(rawValue).json"
  }
  
  func parseUrl(url: URL?) -> URL {
    guard let url else {
      return URL(fileURLWithPath: defaultOutputPath)
    }
    return url
  }
  
  var template: any Encodable {
    switch self {
    case .boiler:
      return ServerRoute.Api.Route.Interpolation.Heating.Boiler.mock
    case .electric:
      return ServerRoute.Api.Route.Interpolation.Heating.Electric.mock
    case .furnace:
      return ServerRoute.Api.Route.Interpolation.Heating.Furnace.mock
    case .heatPump:
      return ServerRoute.Api.Route.Interpolation.Heating.HeatPump.mock
    case .noInterpolation:
      return ServerRoute.Api.Route.Interpolation.Cooling.NoInterpolation.mock
    case .oneWayIndoor:
      return ServerRoute.Api.Route.Interpolation.Cooling.OneWay.indoorMock
    case .oneWayOutdoor:
      return ServerRoute.Api.Route.Interpolation.Cooling.OneWay.outdoorMock
    case .twoWay:
      return ServerRoute.Api.Route.Interpolation.Cooling.TwoWay.mock
    }
  }
  

}
