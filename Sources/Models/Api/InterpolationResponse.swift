// TODO: Add pass / fail results.

public enum InterpolationResponse: Codable, Equatable, Sendable {
  case cooling(Cooling)
  case heating(Heating)

  public struct Cooling: Codable, Equatable, Sendable {
    public let result: Result

    public init(result: Result) {
      self.result = result
    }

    public struct Result: Codable, Equatable, Sendable {
      public let interpolatedCapacity: CoolingCapacity
      public let excessLatent: Int
      public let finalCapacityAtDesign: CoolingCapacity
      public let altitudeDerating: AdjustmentMultiplier?
      public let capacityAsPercentOfLoad: CapacityAsPercentOfLoad

      public init(
        interpolatedCapacity: CoolingCapacity,
        excessLatent: Int,
        finalCapacityAtDesign: CoolingCapacity,
        altitudeDerating: AdjustmentMultiplier?,
        capacityAsPercentOfLoad: CapacityAsPercentOfLoad
      ) {
        self.interpolatedCapacity = interpolatedCapacity
        self.excessLatent = excessLatent
        self.finalCapacityAtDesign = finalCapacityAtDesign
        self.altitudeDerating = altitudeDerating
        self.capacityAsPercentOfLoad = capacityAsPercentOfLoad
      }
    }
  }

  public struct Heating: Codable, Equatable, Sendable {

    public let result: Result

    public init(result: Result) {
      self.result = result
    }

    public enum Result: Codable, Equatable, Sendable {
      case boiler(Boiler)
      case electric(Electric)
      case furnace(Furnace)
      case heatPump(HeatPump)

      public struct Boiler: Codable, Equatable, Sendable {
        public let outputCapacity: Int
        public let finalCapacity: Int
        public let percentOfLoad: Double

        public init(
          outputCapacity: Int,
          finalCapacity: Int,
          percentOfLoad: Double
        ) {
          self.outputCapacity = outputCapacity
          self.finalCapacity = finalCapacity
          self.percentOfLoad = percentOfLoad
        }
      }

      public struct Furnace: Codable, Equatable, Sendable {
        public let outputCapacity: Int
        public let finalCapacity: Int
        public let percentOfLoad: Double

        public init(
          outputCapacity: Int,
          finalCapacity: Int,
          percentOfLoad: Double
        ) {
          self.outputCapacity = outputCapacity
          self.finalCapacity = finalCapacity
          self.percentOfLoad = percentOfLoad
        }
      }

      public struct Electric: Codable, Equatable, Sendable {
        public let requiredKW: Double
        public let percentOfLoad: Double

        public init(
          requiredKW: Double,
          percentOfLoad: Double
        ) {
          self.requiredKW = requiredKW
          self.percentOfLoad = percentOfLoad
        }
      }

      public struct HeatPump: Codable, Equatable, Sendable {
        public let finalCapacity: HeatPumpCapacity
        public let capacityAtDesign: Int
        public let balancePointTemperature: Double
        public let requiredKW: Double

        public init(
          finalCapacity: HeatPumpCapacity,
          capacityAtDesign: Int,
          balancePointTemperature: Double,
          requiredKW: Double
        ) {
          self.finalCapacity = finalCapacity
          self.capacityAtDesign = capacityAtDesign
          self.balancePointTemperature = balancePointTemperature
          self.requiredKW = requiredKW
        }
      }
    }
  }
}

// MARK: - Encoding

extension InterpolationResponse {

  private enum CodingKeys: CodingKey {
    case cooling
    case heating
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .cooling(cooling):
      try container.encode(cooling, forKey: .cooling)
    case let .heating(heating):
      try container.encode(heating, forKey: .heating)
    }
  }
}

extension InterpolationResponse.Heating.Result {
  
  private enum CodingKeys: CodingKey {
    case boiler
    case electric
    case furnace
    case heatPump
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .boiler(boiler):
      try container.encode(boiler, forKey: .boiler)
    case let .electric(electric):
      try container.encode(electric, forKey: .electric)
    case let .furnace(furnace):
      try container.encode(furnace, forKey: .furnace)
    case let .heatPump(heatPump):
      try container.encode(heatPump, forKey: .heatPump)

    }
  }
}
