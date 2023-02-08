import Models
import SiteRouteValidations
import Validations

// MARK: - Cooling Interpolations

extension ServerRoute.Api.Route.InterpolationRequest.Cooling: AsyncValidatable {
  
  public func validate(_ value: ServerRoute.Api.Route.InterpolationRequest.Cooling) async throws {
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

// MARK: - Heating Interpolations


extension ServerRoute.Api.Route.InterpolationRequest.Heating.ElectricRequest: AsyncValidatable {
  
  public var body: some AsyncValidation<Self> {
    AsyncValidator {
      AsyncValidator.validate(\.inputKW, with: .greaterThan(0))
      AsyncValidator.validate(\.houseLoad.heating, with: .greaterThan(0))
    }
  }
}

extension ServerRoute.Api.Route.InterpolationRequest.Heating.HeatPumpRequest: AsyncValidatable {
  
  public var body: some AsyncValidation<Self> {
    AsyncValidator.validate(\.capacity)
  }
}

extension ServerRoute.Api.Route.InterpolationRequest.Heating: AsyncValidatable {
  
  public func validate(_ value: ServerRoute.Api.Route.InterpolationRequest.Heating) async throws {
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

extension ServerRoute.Api.Route.InterpolationRequest: AsyncValidatable {
  
  public func validate(_ value: ServerRoute.Api.Route.InterpolationRequest) async throws {
    switch value {
    case let .cooling(cooling):
      return try await cooling.validate()
    case let .heating(heating):
      return try await heating.validate()
    }
  }
}

// MARK: - RequiredKW
extension ServerRoute.Api.Route.RequiredKWRequest: AsyncValidatable {
  
  public var body: some AsyncValidation<Self> {
    AsyncValidator {
      AsyncValidator.greaterThan(\.heatLoss, 0)
      AsyncValidator.greaterThanOrEquals(\.capacityAtDesign, 0)
    }
  }
}

// MARK: - Balance Point
extension ServerRoute.Api.Route.BalancePointRequest.Thermal: AsyncValidatable {

  public var body: some AsyncValidation<Self> {
    AsyncValidator {
      AsyncValidator.greaterThan(\Self.heatLoss, 0).errorLabel("heatLoss")
      AsyncValidator.validate(\Self.capacity).errorLabel("capacity")
    }
  }
}

extension ServerRoute.Api.Route.BalancePointRequest: AsyncValidatable {
  public func validate(_ value: ServerRoute.Api.Route.BalancePointRequest) async throws {
    switch value {
    case let .thermal(thermal):
      try await thermal.validate()
    }
  }
}

// MARK: Sizing Limits
extension ServerRoute.Api.Route.SizingLimitRequest: AsyncValidatable {
  public func validate(_ value: Models.ServerRoute.Api.Route.SizingLimitRequest) async throws {
    if case let .airToAir(type: _, compressor: _, climate: climate) = value.systemType {
      guard case .coldWinterOrNoLatentLoad = climate else { return }
      guard let load = value.houseLoad else {
        throw ValidationError("House load is required for \(climate).")
      }
      try await SizingLimitValidator(load: load).validate()
    }
  }
}

struct SizingLimitValidator: AsyncValidatable {
  let load: HouseLoad

  var body: some AsyncValidation<Self> {
    Validator.greaterThan(\.load.cooling.total, 0)
  }
}

extension HeatPumpCapacity: AsyncValidatable {
  public typealias Value = Self
  
  public var body: some AsyncValidation<Self> {
    AsyncValidatorOf<Self> {
      AsyncValidator.greaterThan(\Self.at47, 0)
      AsyncValidator.greaterThan(\Self.at17, 0)
      AsyncValidator.greaterThanOrEquals(\Self.at47, \Self.at17)
    }
  }
}
