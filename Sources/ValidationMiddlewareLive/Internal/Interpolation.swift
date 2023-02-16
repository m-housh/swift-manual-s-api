import Models
import Validations

extension ServerRoute.Api.Route.Interpolation.Cooling: AsyncValidatable {

  @inlinable
  public func validate(_ value: ServerRoute.Api.Route.Interpolation.Cooling) async throws {
    switch value {
    case let .noInterpolation(noInterpolation):
      return try await noInterpolation.validate()
    case let .oneWayIndoor(oneWayIndoor):
      return try await OneWayRequestValidation.indoor(oneWayIndoor).validate()
    case let .oneWayOutdoor(oneWayOutdoor):
      return try await OneWayRequestValidation.outdoor(oneWayOutdoor).validate()
    case let .twoWay(twoWay):
      return try await twoWay.validate()
    }
  }
}

extension ServerRoute.Api.Route.Interpolation.Heating: AsyncValidatable {

  @inlinable
  public func validate(_ value: ServerRoute.Api.Route.Interpolation.Heating) async throws {
    switch value {
    case let .boiler(boiler):
      return try await boiler.validate()
    case let .electric(electric):
      return try await electric.validate()
    case let .furnace(furnace):
      return try await furnace.validate()
    case let .heatPump(heatPump):
      return try await heatPump.validate()
    }
  }
}

extension ServerRoute.Api.Route.Interpolation: AsyncValidatable {

  @inlinable
  public func validate(_ value: ServerRoute.Api.Route.Interpolation) async throws {
    switch value {
    case let .cooling(cooling):
      return try await cooling.validate()
    case let .heating(heating):
      return try await heating.validate()
    }
  }
}
