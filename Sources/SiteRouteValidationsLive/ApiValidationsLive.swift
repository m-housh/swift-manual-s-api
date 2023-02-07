import Models
import SiteRouteValidations
import Validations

// MARK: - Cooling Interpolations
extension CoolingCapacity: AsyncValidatable {
  public var body: some AsyncValidation<Self> {
    AsyncValidator {
      AsyncValidator.validate(\.total, with: .greaterThan(0))
        .errorLabel("total")
      
      AsyncValidator.validate(\.sensible, with: .greaterThan(0))
        .errorLabel("sensible")
    }
  }
}

extension CoolingCapacityEnvelope: AsyncValidatable {
  public var body: some AsyncValidation<Self> {
    AsyncValidator.greaterThan(\.cfm, 0)
      .errorLabel("cfm")
    AsyncValidator.greaterThan(\.indoorTemperature, 0)
      .errorLabel("indoor-temperature")
    AsyncValidator.validate(\.capacity)
      .errorLabel("capacity")
  }
}

extension ServerRoute.Api.Route.InterpolationRequest.Cooling.TwoWayRequest.CapacityEnvelope: AsyncValidatable {
  
  private var baseValidator: AsyncValidatorOf<Self> {
    .init {
      AsyncValidator.validate(\Self.above)
        .errorLabel("above")
      AsyncValidator.validate(\Self.below)
        .errorLabel("below")
      AsyncValidator.equals(\Self.above.cfm, \Self.below.cfm)
        .errorLabel("(above, below).cfm")
    }
  }
  
  public var body: some AsyncValidation<Self> {
    AsyncValidator {
      baseValidator
      AsyncValidator.equals(\Self.above.indoorTemperature, \Self.below.indoorTemperature)
        .errorLabel("(above, below).indoor-temperature")
     AsyncValidator.greaterThan(\Self.above.indoorWetBulb, \Self.below.indoorWetBulb)
        .errorLabel("(above, below).indoor-wet-bulb")
     AsyncValidator.greaterThan(\Self.above.indoorWetBulb, 63)
        .errorLabel("above.indoor-wet-bulb")
     AsyncValidator.lessThan(\Self.below.indoorWetBulb, 63)
        .errorLabel("below.indoor-wet-bulb")
    }
  }
}

extension ServerRoute.Api.Route.InterpolationRequest.Cooling.TwoWayRequest: AsyncValidatable {
  public var body: some AsyncValidation<Self> {
    AsyncValidator {
      AsyncValidator.validate(\.aboveDesign)
        .errorLabel("aboveDesign")
      AsyncValidator.validate(\.belowDesign)
        .errorLabel("belowDesign")
      AsyncValidator.lessThan(\.belowDesign.below.outdoorTemperature, \.designInfo.summer.outdoorTemperature)
        .errorLabel("(belowDesign.below.outdoorTemperature, designInfo.summer.outdoorTemperature)")
      AsyncValidator.equals(\.aboveDesign.below.cfm, \.belowDesign.below.cfm)
        .errorLabel("(aboveDesign.below.cfm, belowDesign.below.cfm)")
      AsyncValidator.equals(\.belowDesign.below.indoorTemperature, \.designInfo.summer.indoorTemperature)
        .errorLabel("(belowDesign.below.indoorTemperature, designInfo.summer.indoorTemperature)")
      AsyncValidator.equals(\.aboveDesign.below.indoorTemperature, \.designInfo.summer.indoorTemperature)
        .errorLabel("(aboveDesign.below.indoorTemperature, designInfo.summer.indoorTemperature)")
    }
  }
}

fileprivate enum OneWayRequestValidation: AsyncValidatable {
  
  typealias OneWayRequest = ServerRoute.Api.Route.InterpolationRequest.Cooling.OneWayRequest
  case indoor(OneWayRequest)
  case outdoor(OneWayRequest)
  
  private var baseValidator: AsyncValidator<OneWayRequest> {
    AsyncValidator {
      AsyncValidator.validate(\OneWayRequest.aboveDesign)
      AsyncValidator.validate(\OneWayRequest.belowDesign)
      AsyncValidator.equals(\OneWayRequest.aboveDesign.cfm, \OneWayRequest.belowDesign.cfm)
    }
  }
  
  var outdoorAsyncValidator: any AsyncValidation<OneWayRequest> {
    AsyncValidator<OneWayRequest> {
      baseValidator
      AsyncValidator.equals(\OneWayRequest.aboveDesign.indoorWetBulb, 63)
      AsyncValidator.equals(\OneWayRequest.belowDesign.indoorWetBulb, 63)
      AsyncValidator.lessThan(
        \OneWayRequest.belowDesign.outdoorTemperature,
         \OneWayRequest.designInfo.summer.outdoorTemperature
      )
      AsyncValidator.greaterThan(
        \OneWayRequest.aboveDesign.outdoorTemperature,
         \OneWayRequest.designInfo.summer.outdoorTemperature
      )
    }
  }
  
  var indoorAsyncValidator: any AsyncValidation<OneWayRequest> {
    AsyncValidator {
      AsyncValidator.validate(\.aboveDesign)
      AsyncValidator.validate(\.belowDesign)
      AsyncValidator.equals(\.aboveDesign.cfm, \.belowDesign.cfm)
      AsyncValidator.equals(\.aboveDesign.indoorTemperature, \.belowDesign.indoorTemperature)
      AsyncValidator.lessThan(\.belowDesign.indoorWetBulb, 63)
      AsyncValidator.greaterThan(\.aboveDesign.indoorWetBulb, 63)
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
  public var body: some AsyncValidation<Self> {
    AsyncValidator {
      AsyncValidator.validate(\.capacity)
      AsyncValidator.equals(\.capacity.outdoorTemperature, \.designInfo.summer.outdoorTemperature)
      AsyncValidator.equals(\.capacity.indoorTemperature, \.designInfo.summer.indoorTemperature)
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
  
  public var body: some AsyncValidation<Self> {
    AsyncValidator {
      AsyncValidator.validate(\.afue) {
        Double.greaterThan(0)
        Double.lessThanOrEquals(100)
      }
      AsyncValidator.validate(\.input, with: .greaterThan(0))
    }
  }
}

extension ServerRoute.Api.Route.InterpolationRequest.Heating.FurnaceRequest: AsyncValidatable {
  
  public var body: some AsyncValidation<Self> {
    AsyncValidator {
      AsyncValidator.validate(\.afue) {
        Double.greaterThan(0)
        Double.lessThanOrEquals(100)
      }
      AsyncValidator.validate(\.input, with: .greaterThan(0))
    }
  }
  
}

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
