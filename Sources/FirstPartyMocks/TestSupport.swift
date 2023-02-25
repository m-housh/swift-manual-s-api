import Models
import Tagged

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

extension ServerRoute.Api.Route.Interpolation.Route.Cooling.NoInterpolation {
  public static let zero = Self.init(
    capacity: .zero,
    manufacturerAdjustments: nil
  )

  public static let mock = Self.init(
    capacity: .mock,
    manufacturerAdjustments: .mock
  )
}

extension ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay {

  public static let zero = Self.init(
    aboveDesign: .zero,
    belowDesign: .zero
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
      manufacturerAdjustments: .airToAir(total: 0.98, sensible: 0.95, heating: 1.0)
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
      manufacturerAdjustments: .airToAir(total: 0.98, sensible: 0.95, heating: 1.0)
    )
  }
}

extension Tagged
where RawValue == ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay, Tag == IndoorTag {
  public static var mock: Self { .init(.indoorMock) }
}

extension Tagged
where RawValue == ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay, Tag == OutdoorTag {
  public static var mock: Self { .init(.outdoorMock) }
}

extension Tagged where RawValue == ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay {
  public static var zero: Self { .init(.zero) }
}

extension ServerRoute.Api.Route.Interpolation.Route.Cooling.TwoWay {
  public static let zero = Self.init(
    aboveDesign: .init(aboveWetBulb: .zero, belowWetBulb: .zero),
    belowDesign: .init(aboveWetBulb: .zero, belowWetBulb: .zero)
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
    manufacturerAdjustments: .airToAir(total: 1.0, sensible: 1.0, heating: 1.0)
  )
}

extension ServerRoute.Api.Route.Interpolation.Route.Heating.Boiler {

  public static let zero = Self.init(
    input: 0,
    afue: 0
  )

  public static let mock = Self.init(
    input: 60_000,
    afue: 96.5
  )
}

extension ServerRoute.Api.Route.Interpolation.Route.Heating.Furnace {

  public static let zero = Self.init(
    input: 0,
    afue: 0
  )

  public static let mock = Self.init(
    input: 60_000,
    afue: 96.5
  )
}

extension ServerRoute.Api.Route.Interpolation.Route.Heating.Electric {

  public static let zero = Self.init(
    heatPumpCapacity: nil,
    inputKW: 0
  )

  public static let mock = Self.init(
    heatPumpCapacity: 23_200,
    inputKW: 15
  )
}

extension ServerRoute.Api.Route.Interpolation.Route.Heating.HeatPump {

  public static let zero = Self.init(
    capacity: .zero
  )

  public static let mock = Self.init(
    capacity: .mock
  )
}

extension ServerRoute.Api.Route.RequiredKW {
  public static let zero = Self.init(
    capacityAtDesign: 0,
    heatLoss: 0
  )

  public static let mock = Self.init(
    capacityAtDesign: 23_123,
    heatLoss: 49_667
  )
}

extension ServerRoute.Api.Route.BalancePoint.Thermal {
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

extension ServerRoute.Api.Route.Derating {

  public static let zero = Self.init(elevation: 0, systemType: .mock)

  public static let mock = Self.init(elevation: 5_000, systemType: .mock)
}

extension ServerRoute.Api.Route.SizingLimit {
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

extension ServerRoute.Api.Route.Interpolation {

  public static func mock(route: ServerRoute.Api.Route.Interpolation.Route) -> Self {
    .init(designInfo: .mock, houseLoad: .mock, systemType: .default, route: route)
  }
}

extension ServerRoute.Api.Route.Interpolation.Route.Keyed {
  
  public static let mocks: [Self] = [
    .init(
      key: "system-1",
      cooling: .noInterpolation(.mock),
      heating: [
        .furnace(.mock)
      ]
    ),
    .init(
      key: "system-2",
      cooling: .oneWayIndoor(.mock),
      heating: [
        .heatPump(.mock),
        .furnace(.mock)
      ]
    ),
    .init(
      key: "system-3",
      cooling: .twoWay(.mock),
      heating: [
        .heatPump(.mock),
        .furnace(.mock)
      ]
    )
  ]
  
  public static let zeros: [Self] = [
    .init(
      key: "system-1",
      cooling: .noInterpolation(.zero),
      heating: [
        .furnace(.zero)
      ]
    ),
    .init(
      key: "system-2",
      cooling: .oneWayIndoor(.zero),
      heating: [
        .heatPump(.mock),
        .furnace(.mock)
      ]
    ),
    .init(
      key: "system-3",
      cooling: .twoWay(.zero),
      heating: [
        .heatPump(.zero),
        .furnace(.zero)
      ]
    )
  ]
}

extension Array where Element == ServerRoute.Api.Route.Interpolation.Route.Keyed {
  public static var mocks: Self { ServerRoute.Api.Route.Interpolation.Route.Keyed.mocks }
  public static var zeros: Self { ServerRoute.Api.Route.Interpolation.Route.Keyed.zeros }
}
