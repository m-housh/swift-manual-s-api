import Models
import Validations

// TODO: Add basic validations for houseLoad, designInfo, etc.
extension ServerRoute.Api.Route.Interpolation: AsyncValidatable {

  @inlinable
  public func validate(_ value: ServerRoute.Api.Route.Interpolation) async throws {
    switch value.route {
    case let .cooling(route: cooling):
      switch cooling {
      case let .noInterpolation(noInterpolation):
        try await NoInterpolationValidator(request: self, noInterpolation: noInterpolation)
          .validate()
      case let .oneWayIndoor(indoor):
        try await OneWayIndoorValidation(request: self, oneWayIndoor: indoor.rawValue).validate()
      case let .oneWayOutdoor(outdoor):
        try await OneWayOutdoorValidation(request: self, oneWayOutdoor: outdoor.rawValue).validate()
      case let .twoWay(twoWay):
        try await TwoWayValidation(request: self, twoWay: twoWay).validate()
      }
    case .heating(route: _):
      fatalError()
    case .keyed(_):
      fatalError()
    }
  }
}

//extension ServerRoute.Api.Route.Interpolation.Route.Cooling: AsyncValidatable {
//
//  @inlinable
//  public func validate(_ value: ServerRoute.Api.Route.Interpolation.Route.Cooling) async throws {
//    switch value {
//    case let .noInterpolation(noInterpolation):
//      return try await noInterpolation.validate()
//    case let .oneWayIndoor(oneWayIndoor):
//      return try await OneWayRequestValidation.indoor(oneWayIndoor.rawValue).validate()
//    case let .oneWayOutdoor(oneWayOutdoor):
//      return try await OneWayRequestValidation.outdoor(oneWayOutdoor.rawValue).validate()
//    case let .twoWay(twoWay):
//      return try await twoWay.validate()
//    }
//  }
//}
//
//extension ServerRoute.Api.Route.Interpolation.Route.Heating: AsyncValidatable {
//
//  @inlinable
//  public func validate(_ value: ServerRoute.Api.Route.Interpolation.Route.Heating) async throws {
//    switch value {
//    case let .boiler(boiler):
//      return try await boiler.validate()
//    case let .electric(electric):
//      return try await electric.validate()
//    case let .furnace(furnace):
//      return try await furnace.validate()
//    case let .heatPump(heatPump):
//      return try await heatPump.validate()
//    }
//  }
//}
//
//extension ServerRoute.Api.Route.Interpolation.Route: AsyncValidatable {
//
//  @inlinable
//  public func validate(_ value: ServerRoute.Api.Route.Interpolation.Route) async throws {
//    switch value {
//    case let .cooling(cooling):
//      return try await cooling.validate()
//    case let .heating(heating):
//      return try await heating.validate()
//    case .keyed(_):
//      return
//      // FIX ME
////      for value in keyed {
////        if let cooling = value.route.left {
////          try await cooling.validate()
////        } else if let heating = value.route.right {
////          try await heating.validate()
////        }
////      }
//    }
//  }
//}
