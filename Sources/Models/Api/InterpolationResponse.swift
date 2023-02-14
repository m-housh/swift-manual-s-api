// TODO: Add pass / fail results.

public struct InterpolationResponseEnvelope: Codable, Equatable, Sendable {
  public let failures: [String]?
  public let result: InterpolationResponse
  // not a computed property, so it get's encoded in json responses.
  public let isFailed: Bool
  
  public init(
    failures: [String]? = nil,
    result: InterpolationResponse
  ) {
    self.failures = failures
    self.result = result
    if let failures {
      self.isFailed = !failures.isEmpty
    } else {
      self.isFailed = false
    }
  }
}

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
      public let sizingLimits: SizingLimits

      public init(
        interpolatedCapacity: CoolingCapacity,
        excessLatent: Int,
        finalCapacityAtDesign: CoolingCapacity,
        altitudeDerating: AdjustmentMultiplier?,
        capacityAsPercentOfLoad: CapacityAsPercentOfLoad,
        sizingLimits: SizingLimits
      ) {
        self.interpolatedCapacity = interpolatedCapacity
        self.excessLatent = excessLatent
        self.finalCapacityAtDesign = finalCapacityAtDesign
        self.altitudeDerating = altitudeDerating
        self.capacityAsPercentOfLoad = capacityAsPercentOfLoad
        self.sizingLimits = sizingLimits
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
        public let sizingLimits: SizingLimits

        public init(
          outputCapacity: Int,
          finalCapacity: Int,
          percentOfLoad: Double
        ) {
          self.outputCapacity = outputCapacity
          self.finalCapacity = finalCapacity
          self.percentOfLoad = percentOfLoad
          self.sizingLimits = .init(oversizing: .boiler(), undersizing: .boiler())
        }
      }

      public struct Furnace: Codable, Equatable, Sendable {
        public let outputCapacity: Int
        public let finalCapacity: Int
        public let percentOfLoad: Double
        public let sizingLimits: SizingLimits

        public init(
          outputCapacity: Int,
          finalCapacity: Int,
          percentOfLoad: Double
        ) {
          self.outputCapacity = outputCapacity
          self.finalCapacity = finalCapacity
          self.percentOfLoad = percentOfLoad
          self.sizingLimits = .init(oversizing: .furnace(), undersizing: .furnace())
        }
      }

      public struct Electric: Codable, Equatable, Sendable {
        public let requiredKW: Double
        public let percentOfLoad: Double
        public let sizingLimits: SizingLimits

        public init(
          requiredKW: Double,
          percentOfLoad: Double
        ) {
          self.requiredKW = requiredKW
          self.percentOfLoad = percentOfLoad
          self.sizingLimits = .init(oversizing: .electricFurnace(), undersizing: .electricFurnace())
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
