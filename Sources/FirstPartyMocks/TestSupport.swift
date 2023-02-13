import Models

// This file contains extension on model types to be used in tests, these are generally not needed,
// however they need to be public to test release builds.

extension CoolingCapacity {
  public static var mock = Self.init(
    total: 22_000,
    sensible: 16_600
  )
}

extension ManufactuerCoolingCapacity {

  public static var zero = Self.init(
    cfm: 0,
    indoorTemperature: 0,
    indoorWetBulb: 0,
    outdoorTemperature: 0,
    capacity: .zero
  )

  public static var mock = Self.init(
    cfm: 800,
    indoorTemperature: 75,
    indoorWetBulb: 63,
    outdoorTemperature: 90,
    capacity: .mock
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

extension AdjustmentMultiplier {
  public static let mock = Self.airToAir(total: 1.0, sensible: 1.0, heating: 1.0)
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

  public static let mock = Self.init(
    capacity: .mock,
    designInfo: .mock,
    houseLoad: .mock,
    manufacturerAdjustments: .mock,
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

  public static var outdoorMock: Self {
    var aboveDesign = ManufactuerCoolingCapacity.mock
    aboveDesign.outdoorTemperature = 95

    var belowDesign = ManufactuerCoolingCapacity.mock
    belowDesign.outdoorTemperature = 85
    belowDesign.capacity = .init(total: 23_200, sensible: 17_100)

    return .init(
      aboveDesign: aboveDesign,
      belowDesign: belowDesign,
      designInfo: .mock,
      houseLoad: .mock,
      systemType: .mock
    )
  }

  public static var indoorMock: Self {
    var aboveDesign = ManufactuerCoolingCapacity.mock
    aboveDesign.indoorWetBulb = 67
    aboveDesign.outdoorTemperature = 95
    aboveDesign.capacity = .init(total: 24_828, sensible: 15_937)

    var belowDesign = ManufactuerCoolingCapacity.mock
    belowDesign.outdoorTemperature = 95
    belowDesign.indoorWetBulb = 62
    belowDesign.capacity = .init(total: 23_046, sensible: 19_078)

    return .init(
      aboveDesign: aboveDesign,
      belowDesign: belowDesign,
      designInfo: .mock,
      houseLoad: .mock,
      systemType: .mock
    )
  }
}

extension ServerRoute.Api.Route.InterpolationRequest.Cooling.TwoWayRequest {
  public static let zero = Self.init(
    aboveDesign: .init(aboveWetBulb: .zero, belowWetBulb: .zero),
    belowDesign: .init(aboveWetBulb: .zero, belowWetBulb: .zero),
    designInfo: .zero,
    houseLoad: .zero,
    systemType: .mock
  )
  
  public static let mock = Self.init(
    aboveDesign: .init(
      aboveWetBulb: .init(
        cfm: 800,
        indoorTemperature: 75,
        indoorWetBulb: 67,
        outdoorTemperature: 95,
        capacity: .init(total: 24_828, sensible: 15_937)
      ),
      belowWetBulb: .init(
        cfm: 800,
        indoorTemperature: 75,
        indoorWetBulb: 62,
        outdoorTemperature: 95,
        capacity: .init(total: 23_046, sensible: 19_078)
      )
    ),
    belowDesign: .init(
      aboveWetBulb: .init(
        cfm: 800,
        indoorTemperature: 75,
        indoorWetBulb: 67,
        outdoorTemperature: 85,
        capacity: .init(total: 25_986, sensible: 16_330)
      ),
      belowWetBulb: .init(
        cfm: 800,
        indoorTemperature: 75,
        indoorWetBulb: 62,
        outdoorTemperature: 85,
        capacity: .init(total: 24_029, sensible: 19_605)
      )
    ),
    designInfo: .mock,
    houseLoad: .mock,
    manufacturerAdjustments: .airToAir(total: 1.0, sensible: 1.0, heating: 1.0),
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
  
  public static let mock = Self.init(
    altitudeDeratings: .heating(multiplier: 1.0),
    houseLoad: .mock,
    input: 60_000,
    afue: 96.5
  )
}

extension ServerRoute.Api.Route.InterpolationRequest.Heating.FurnaceRequest {

  public static let zero = Self.init(
    altitudeDeratings: nil,
    houseLoad: .zero,
    input: 0,
    afue: 0
  )
  
  public static let mock = Self.init(
    altitudeDeratings: .heating(multiplier: 1.0),
    houseLoad: .mock,
    input: 60_000,
    afue: 96.5
  )
}

extension ServerRoute.Api.Route.InterpolationRequest.Heating.ElectricRequest {

  public static let zero = Self.init(
    altitudeDeratings: nil,
    heatPumpCapacity: nil,
    houseLoad: .zero,
    inputKW: 0
  )
  
  public static let mock = Self.init(
    altitudeDeratings: .heating(multiplier: 1.0),
    heatPumpCapacity: 23_200,
    houseLoad: .mock,
    inputKW: 15
  )
}

extension ServerRoute.Api.Route.InterpolationRequest.Heating.HeatPumpRequest {

  public static let zero = Self.init(
    altitudeDeratings: nil,
    capacity: .zero,
    designInfo: .zero,
    houseLoad: .zero
  )
  
  public static let mock = Self.init(
    altitudeDeratings: .airToAir(total: 1.0, sensible: 1.0, heating: 1.0),
    capacity: .mock,
    designInfo: .mock,
    houseLoad: .mock
  )
}

extension ServerRoute.Api.Route.RequiredKWRequest {
  public static let zero = Self.init(
    capacityAtDesign: 0,
    heatLoss: 0
  )

  public static let mock = Self.init(
    capacityAtDesign: 23_123,
    heatLoss: 49_667
  )
}

extension ServerRoute.Api.Route.BalancePointRequest.Thermal {
  public static let zero = Self.init(
    designTemperature: 0,
    heatLoss: 0,
    capacity: .zero
  )

  public static let mock = Self.init(
    designTemperature: 5,
    heatLoss: 49_667,
    capacity: .mock
  )
}

extension ServerRoute.Api.Route.DeratingRequest {

  public static let zero = Self.init(elevation: 0, systemType: .mock)

  public static let mock = Self.init(elevation: 5_000, systemType: .mock)
}

extension ServerRoute.Api.Route.SizingLimitRequest {
  public static let zero = Self.init(
    systemType: .mock,
    houseLoad: .zero
  )

  public static let mock = Self.init(
    systemType: .mock,
    houseLoad: .mock
  )
}

extension SystemType {
  public static let mock: Self = .airToAir(
    type: .heatPump, compressor: .variableSpeed, climate: .mildWinterOrLatentLoad)
}
