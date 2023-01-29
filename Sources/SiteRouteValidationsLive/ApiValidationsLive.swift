import Models
import SiteRouteValidations
import Validations

// MARK: - Cooling Interpolations
extension CoolingCapacity: Validatable {
  public var body: some Validator<Self> {
    Validation {
      GreaterThan(\.total, 0)
      GreaterThan(\.sensible, 0)
    }
  }
}

extension CoolingCapacityEnvelope: Validatable {
  public var body: some Validator<Self> {
    Validation {
      GreaterThan(\.cfm, 0)
      Validate(\.capacity)
      GreaterThan(\.indoorTemperature, 0)
    }
  }
}

extension ServerRoute.Api.Route.InterpolationRequest.Cooling.TwoWayRequest.CapacityEnvelope: Validatable {
  public var body: some Validator<Self> {
    Validation {
      Validate(\.above)
      Validate(\.below)
      Equals(\.above.cfm, \.below.cfm)
      Equals(\.above.indoorTemperature, \.below.indoorTemperature)
      GreaterThan(\.above.indoorWetBulb, \.below.indoorWetBulb)
      GreaterThan(\.above.indoorWetBulb, 63)
      Not(GreaterThan(\.below.indoorWetBulb, 63))
    }
  }
}

extension ServerRoute.Api.Route.InterpolationRequest.Cooling.TwoWayRequest: AsyncValidatable {
  public var body: some AsyncValidator<Self> {
    AsyncValidation {
      Validate(\.aboveDesign)
      Validate(\.belowDesign)
      Not(GreaterThan(\.belowDesign.below.outdoorTemperature, \.designInfo.summer.outdoorTemperature))
      Equals(\.aboveDesign.below.cfm, \.belowDesign.below.cfm)
      Equals(\.belowDesign.below.indoorTemperature, \.designInfo.summer.indoorTemperature)
      Equals(\.aboveDesign.below.indoorTemperature, \.designInfo.summer.indoorTemperature)
    }
  }
}

fileprivate enum OneWayRequestValidation: AsyncValidatable {
  
  typealias OneWayRequest = ServerRoute.Api.Route.InterpolationRequest.Cooling.OneWayRequest
  case indoor(OneWayRequest)
  case outdoor(OneWayRequest)
  
  var outdoorAsyncValidator: any AsyncValidator<OneWayRequest> {
    AsyncValidation {
      Validate(\.aboveDesign)
      Validate(\.belowDesign)
      Equals(\.aboveDesign.cfm, \.belowDesign.cfm)
      Equals(\.aboveDesign.indoorWetBulb, 63)
      Equals(\.belowDesign.indoorWetBulb, 63)
      Not(GreaterThan(\.belowDesign.outdoorTemperature, \.designInfo.summer.outdoorTemperature))
      GreaterThan(\.aboveDesign.outdoorTemperature, \.designInfo.summer.outdoorTemperature)
    }
  }
  
  var indoorAsyncValidator: any AsyncValidator<OneWayRequest> {
    AsyncValidation {
      Validate(\.aboveDesign)
      Validate(\.belowDesign)
      Equals(\.aboveDesign.cfm, \.belowDesign.cfm)
      Equals(\.aboveDesign.indoorTemperature, \.belowDesign.indoorTemperature)
      Not(GreaterThan(\.belowDesign.indoorWetBulb, 63))
      GreaterThan(\.aboveDesign.indoorWetBulb, 63)
    }
  }
  
  func validate(_ value: Self) async throws {
    switch value {
    case let .indoor(indoorRequest):
      return try await indoorAsyncValidator.validate(indoorRequest)
    case let .outdoor(outdoorRequest):
      return try await outdoorAsyncValidator.validate(outdoorRequest)
    }
  }
}

extension ServerRoute.Api.Route.InterpolationRequest.Cooling.NoInterpolationRequest: AsyncValidatable {
  public var body: some AsyncValidator<Self> {
    AsyncValidation {
      Validate(\.capacity)
      Equals(\.capacity.outdoorTemperature, \.designInfo.summer.outdoorTemperature)
      Equals(\.capacity.indoorTemperature, \.designInfo.summer.indoorTemperature)
    }
  }
}

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
extension ServerRoute.Api.Route.InterpolationRequest.Heating.BoilerRequest: AsyncValidatable {
  
  public var body: some AsyncValidator<Self> {
    AsyncValidation {
      Validate(\.afue) {
        GreaterThan(0)
        Not(GreaterThan(100))
      }
      GreaterThan(\.input, 0)
    }
  }
}

extension ServerRoute.Api.Route.InterpolationRequest.Heating.FurnaceRequest: AsyncValidatable {
  
  public var body: some AsyncValidator<Self> {
    AsyncValidation {
      Validate(\.afue) {
        GreaterThan(0)
        Not(GreaterThan(100))
      }
      GreaterThan(\.input, 0)
    }
  }
}

extension ServerRoute.Api.Route.InterpolationRequest.Heating.ElectricRequest: AsyncValidatable {
  
  public var body: some AsyncValidator<Self> {
    AsyncValidation {
      GreaterThan(\.inputKW, 0)
      GreaterThan(\.houseLoad.heating, 0)
    }
  }
}

extension ServerRoute.Api.Route.InterpolationRequest.Heating.HeatPumpRequest: AsyncValidatable {
  
  public var body: some AsyncValidator<Self> {
    Validate(\.capacity).async
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
  
  public var body: some AsyncValidator<Self> {
    AsyncValidation {
      GreaterThan(\.heatLoss, 0)
      GreaterThanOrEquals(\.capacityAtDesign, 0)
    }
  }
}

// MARK: - Balance Point
extension ServerRoute.Api.Route.BalancePointRequest.Thermal: AsyncValidatable {

  public var body: some AsyncValidator<Self> {
    AsyncValidation {
      GreaterThan(\.heatLoss, 0)
      Validate(\.capacity)
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

  var body: some AsyncValidator<Self> {
    GreaterThan(\.load.cooling.total, 0).async
  }
}

extension HeatPumpCapacity: Validatable {
  public typealias Value = Self
  
  public var body: some Validator<Self> {
    ValidatorOf<Self> {
      GreaterThan(\Self.at47, 0)
      GreaterThan(\Self.at17, 0)
      GreaterThanOrEquals(\Self.at47, \Self.at17)
    }
  }
}
