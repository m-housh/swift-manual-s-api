import Models

// This file contains extension on model types to be used in tests, these are generally not needed,
// however they need to be public to test release builds.

extension CoolingCapacityEnvelope {

  public static var zero = Self.init(
    cfm: 0,
    indoorTemperature: 0,
    indoorWetBulb: 0,
    outdoorTemperature: 0,
    capacity: .zero
  )
}

extension DesignInfo {

  public static let zero = Self.init(
    summer: .init(outdoorTemperature: 0, indoorTemperature: 0, indoorHumidity: 0),
    winter: .init(outdoorTemperature: 0),
    elevation: 0
  )

  public static let mock = Self.init()
}

extension HeatPumpCapacity {

  /// Convenience for heat-pump capacity initialized at zero.
  public static let zero = Self.init(at47: 0, at17: 0)

  /// Convenience for a mock value, used in views and tests.
  public static let mock = Self.init(at47: 24_600, at17: 15_100)
}

extension HouseLoad {

  public static let mock = Self.init(heating: 49_667, cooling: .mock)
}

extension HouseLoad.CoolingLoad {

  public static let mock = Self.init(total: 17_872, sensible: 13_894)

}

extension ServerRoute.Api.Route.InterpolationRequest.Cooling.NoInterpolationRequest {
  public static let zero = Self.init(
    capacity: .zero,
    designInfo: .zero,
    houseLoad: .zero,
    manufacturerAdjustments: nil,
    systemType: .mock
  )
}

extension ServerRoute.Api.Route.InterpolationRequest.Cooling.OneWayRequest {

  public static let zero = Self.init(
    aboveDesign: .zero,
    belowDesign: .zero,
    designInfo: .zero,
    houseLoad: .zero,
    systemType: .mock
  )
}

extension ServerRoute.Api.Route.InterpolationRequest.Cooling.TwoWayRequest {
  public static let zero = Self.init(
    aboveDesign: .init(above: .zero, below: .zero),
    belowDesign: .init(above: .zero, below: .zero),
    designInfo: .zero,
    houseLoad: .zero,
    systemType: .mock
  )
}

extension ServerRoute.Api.Route.InterpolationRequest.Heating.BoilerRequest {

  public static let zero = Self.init(
    altitudeDeratings: nil,
    houseLoad: .zero,
    input: 0,
    afue: 0
  )
}

extension ServerRoute.Api.Route.InterpolationRequest.Heating.FurnaceRequest {

  public static let zero = Self.init(
    altitudeDeratings: nil,
    houseLoad: .zero,
    input: 0,
    afue: 0
  )
}

extension ServerRoute.Api.Route.InterpolationRequest.Heating.ElectricRequest {

  public static let zero = Self.init(
    altitudeDeratings: nil,
    heatPumpCapacity: nil,
    houseLoad: .zero,
    inputKW: 0
  )
}

extension ServerRoute.Api.Route.InterpolationRequest.Heating.HeatPumpRequest {

  public static let zero = Self.init(
    altitudeDeratings: nil,
    capacity: .zero,
    designInfo: .zero,
    houseLoad: .zero
  )
}

extension ServerRoute.Api.Route.RequiredKWRequest {
  public static let zero = Self.init(
    capacityAtDesign: 0,
    heatLoss: 0
  )
}

extension ServerRoute.Api.Route.BalancePointRequest.Thermal {
  public static let zero = Self.init(
    designTemperature: 0,
    heatLoss: 0,
    capacity: .zero
  )
}

extension ServerRoute.Api.Route.SizingLimitRequest {
  public static let zero = Self.init(
    systemType: .mock,
    houseLoad: .zero
  )
}

extension SystemType {
  public static let mock: Self = .airToAir(
    type: .heatPump, compressor: .variableSpeed, climate: .mildWinterOrLatentLoad)
}
