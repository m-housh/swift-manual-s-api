import ArgumentParser
import CliMiddleware
import FirstPartyMocks
import Foundation
import Models

// TODO: Add keyed
//enum InterpolationName: String, EnumerableFlag {
//  case boiler
//  case electric
//  case furnace
//  case heatPump
//  case noInterpolation
//  case oneWayIndoor
//  case oneWayOutdoor
//  case twoWay

extension CliMiddleware.InterpolationName: EnumerableFlag {}

extension CliMiddleware.InterpolationName {
  var defaultOutputPath: String {
    "./\(rawValue).json"
  }

  func parseUrl(url: URL?) -> URL {
    guard let url else {
      return URL(fileURLWithPath: defaultOutputPath)
    }
    guard url.isFileURL && url.pathExtension == "json" else {
      return url.appendingPathComponent(defaultOutputPath)
    }
    return url
  }
}

//  var template: any Encodable {
//    switch self {
//    case .boiler:
//      return ServerRoute.Api.Route.Interpolation.Route.Heating.Boiler.mock
//    case .electric:
//      return ServerRoute.Api.Route.Interpolation.Route.Heating.Electric.mock
//    case .furnace:
//      return ServerRoute.Api.Route.Interpolation.Route.Heating.Furnace.mock
//    case .heatPump:
//      return ServerRoute.Api.Route.Interpolation.Route.Heating.HeatPump.mock
//    case .noInterpolation:
//      return ServerRoute.Api.Route.Interpolation.Route.Cooling.NoInterpolation.mock
//    case .oneWayIndoor:
//      return ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay.indoorMock
//    case .oneWayOutdoor:
//      return ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay.outdoorMock
//    case .twoWay:
//      return ServerRoute.Api.Route.Interpolation.Route.Cooling.TwoWay.mock
//    }
//  }
//
//}
