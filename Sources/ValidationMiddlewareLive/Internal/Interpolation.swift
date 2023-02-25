import Models
import Validations

// TODO: Add basic validations for houseLoad, designInfo, etc.
extension ServerRoute.Api.Route.Interpolation: AsyncValidatable {

  @inlinable
  public func validate(_ value: ServerRoute.Api.Route.Interpolation) async throws {
    switch value.route {
    case let .cooling(route: cooling):
      try await cooling.validate(request: self)
    case let .heating(route: heating):
      try await heating.validate(request: self)
    case let .keyed(keyed):
      try await keyed.validate(request: self)
    }
  }
}

extension ServerRoute.Api.Route.Interpolation.Route.Cooling {
  
  @usableFromInline
  func validate(request: ServerRoute.Api.Route.Interpolation) async throws {
    switch self {
    case let .noInterpolation(noInterpolation):
      try await NoInterpolationValidator(request: request, noInterpolation: noInterpolation)
        .validate()
    case let .oneWayIndoor(indoor):
      try await OneWayIndoorValidation(request: request, oneWayIndoor: indoor.rawValue).validate()
    case let .oneWayOutdoor(outdoor):
      try await OneWayOutdoorValidation(request: request, oneWayOutdoor: outdoor.rawValue).validate()
    case let .twoWay(twoWay):
      try await TwoWayValidation(request: request, twoWay: twoWay).validate()
    }
    
  }
}

extension ServerRoute.Api.Route.Interpolation.Route.Heating {
  @usableFromInline
  func validate(request: ServerRoute.Api.Route.Interpolation) async throws {
    switch self {
    case let .boiler(boiler):
      try await HeatingValidation(
        request: request, interpolation: boiler, errorLabel: "Boiler Request Errors"
      ).validate()
    case let .electric(electric):
      try await HeatingValidation(
        request: request, interpolation: electric, errorLabel: "Electric Request Errors"
      ).validate()
    case let .furnace(furnace):
      try await HeatingValidation(
        request: request, interpolation: furnace, errorLabel: "Furnace Request Errors"
      ).validate()
    case let .heatPump(heatPump):
      try await HeatingValidation(
        request: request, interpolation: heatPump, errorLabel: "Heat Pump Request Errors"
      ).validate()
    }
  }
}
