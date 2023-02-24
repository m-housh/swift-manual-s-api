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
    case let .heating(route: heating):
      switch heating {
      case let .boiler(boiler):
        try await HeatingValidation(
          request: self, interpolation: boiler, errorLabel: "Boiler Request Errors"
        ).validate()
      case let .electric(electric):
        try await HeatingValidation(
          request: self, interpolation: electric, errorLabel: "Electric Request Errors"
        ).validate()
      case let .furnace(furnace):
        try await HeatingValidation(
          request: self, interpolation: furnace, errorLabel: "Furnace Request Errors"
        ).validate()
      case let .heatPump(heatPump):
        try await HeatingValidation(
          request: self, interpolation: heatPump, errorLabel: "Heat Pump Request Errors"
        ).validate()
      }
    case .keyed(_):
      fatalError()
    }
  }
}
