// TODO: Add pass / fail results.

/// Represents the response for an interpolation request.
///
public struct InterpolationResponse: Codable, Equatable, Sendable {
  public let failures: [String]?
  public let result: InterpolationResult
  // not a computed property, so it get's encoded in json responses.
  public let isFailed: Bool

  public init(
    failures: [String]? = nil,
    result: InterpolationResult
  ) {
    self.failures = failures
    self.result = result
    self.isFailed = failures != nil ? failures!.isEmpty : false
  }
}

public enum InterpolationResult: Codable, Equatable, Sendable {
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
        public let altitudeDeratings: AdjustmentMultiplier
        public let outputCapacity: Int
        public let finalCapacity: Int
        public let percentOfLoad: Double
        public let sizingLimits: SizingLimits

        public init(
          altitudeDeratings: AdjustmentMultiplier,
          outputCapacity: Int,
          finalCapacity: Int,
          percentOfLoad: Double
        ) {
          self.altitudeDeratings = altitudeDeratings
          self.outputCapacity = outputCapacity
          self.finalCapacity = finalCapacity
          self.percentOfLoad = percentOfLoad
          self.sizingLimits = .init(oversizing: .boiler(), undersizing: .boiler())
        }
      }

      public struct Furnace: Codable, Equatable, Sendable {
        public let altitudeDeratings: AdjustmentMultiplier
        public let outputCapacity: Int
        public let finalCapacity: Int
        public let percentOfLoad: Double
        public let sizingLimits: SizingLimits

        public init(
          altitudeDeratings: AdjustmentMultiplier,
          outputCapacity: Int,
          finalCapacity: Int,
          percentOfLoad: Double
        ) {
          self.altitudeDeratings = altitudeDeratings
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
          self.sizingLimits = .init(oversizing: .electric(), undersizing: .electric())
        }
      }

      public struct HeatPump: Codable, Equatable, Sendable {
        public let altitudeDeratings: AdjustmentMultiplier
        public let finalCapacity: HeatPumpCapacity
        public let capacityAtDesign: Int
        public let balancePointTemperature: Double
        public let requiredKW: Double

        public init(
          altitudeDeratings: AdjustmentMultiplier,
          finalCapacity: HeatPumpCapacity,
          capacityAtDesign: Int,
          balancePointTemperature: Double,
          requiredKW: Double
        ) {
          self.altitudeDeratings = altitudeDeratings
          self.finalCapacity = finalCapacity
          self.capacityAtDesign = capacityAtDesign
          self.balancePointTemperature = balancePointTemperature
          self.requiredKW = requiredKW
        }
      }
    }
  }
}

// MARK: - Coding

extension InterpolationResult {

  private enum CodingKeys: CodingKey {
    case cooling
    case heating
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .cooling(cooling):
      try container.encode(cooling.result, forKey: .cooling)
    case let .heating(heating):
      try container.encode(heating.result, forKey: .heating)
    }
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let cooling = try? container.decode(InterpolationResult.Cooling.Result.self, forKey: .cooling) {
      self = .cooling(.init(result: cooling))
      return
    } else if let heating = try? container.decode(InterpolationResult.Heating.Result.self, forKey: .heating) {
      self = .heating(.init(result: heating))
      return
    }
    struct DecodingError: Error { }
    throw DecodingError()
  }
}

extension InterpolationResult.Heating.Result {

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
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    if let boiler = try? container.decode(InterpolationResult.Heating.Result.Boiler.self, forKey: .boiler) {
      self = .boiler(boiler)
      return
    } else if let electric = try? container.decode(InterpolationResult.Heating.Result.Electric.self, forKey: .electric) {
      self = .electric(electric)
      return
    } else if let furnace = try? container.decode(InterpolationResult.Heating.Result.Furnace.self, forKey: .furnace) {
      self = .furnace(furnace)
      return
    } else if let heatPump = try? container.decode(InterpolationResult.Heating.Result.HeatPump.self, forKey: .heatPump) {
      self = .heatPump(heatPump)
      return
    }
    
    struct DecodingError: Error { }
    throw DecodingError()
  }
}
