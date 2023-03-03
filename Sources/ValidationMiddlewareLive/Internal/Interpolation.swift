import Foundation
import Models
import Validations

extension ServerRoute.Api.Route.Interpolation: AsyncValidatable {

  public func validate(_ value: Self) async throws {
    switch value {
    case let .single(single):
      try await single.validate()
    case let .project(project):
      try await project.validate()
    }
  }
}

extension ServerRoute.Api.Route.Interpolation.Single: AsyncValidatable {

  @inlinable
  public func validate(_ value: ServerRoute.Api.Route.Interpolation.Single)
    async throws
  {
    switch value.route {
    case let .cooling(route: cooling):
      try await cooling.validate(request: self)
    case let .heating(route: heating):
      try await heating.validate(request: self)
    }
  }
}

extension ServerRoute.Api.Route.Interpolation.Single.Route.Cooling {

  @usableFromInline
  func validate(request: ServerRoute.Api.Route.Interpolation.Single) async throws {
    switch self {
    case let .noInterpolation(noInterpolation):
      try await NoInterpolationValidator(request: request, noInterpolation: noInterpolation)
        .validate()
    case let .oneWayIndoor(indoor):
      try await OneWayIndoorValidation(request: request, oneWayIndoor: indoor.rawValue).validate()
    case let .oneWayOutdoor(outdoor):
      try await OneWayOutdoorValidation(request: request, oneWayOutdoor: outdoor.rawValue)
        .validate()
    case let .twoWay(twoWay):
      try await TwoWayValidation(request: request, twoWay: twoWay).validate()
    }
  }
}

extension ServerRoute.Api.Route.Interpolation.Single.Route.Heating {
  @usableFromInline
  func validate(request: ServerRoute.Api.Route.Interpolation.Single) async throws {
    switch self {
    case let .boiler(boiler):
      try await HeatingValidation<
        ServerRoute.Api.Route.Interpolation.Single.Route.Heating.Boiler
      >(
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
