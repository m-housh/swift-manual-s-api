/// Represents system types for manual-s interpolations.
public enum SystemType: Codable, Equatable, Sendable {

  /// Represents air-conditioner or heat-pump system types.
  case airToAir(AirToAir)

  case heatingOnly(HeatingOnly)

  /// Represents a gas / propane / oil furnace system type.
  //  case furnaceOnly
  public static var furnaceOnly: Self { .heatingOnly(.furnace) }

  /// Represents a gas / propane / oil boiler system type.
  //  case boilerOnly
  public static var boilerOnly: Self { .heatingOnly(.boiler) }

  public static var electricOnly: Self { .heatingOnly(.electric) }

  /// A default system type.
  public static var `default`: Self {
    .airToAir(type: .heatPump, compressor: .variableSpeed, climate: .mildWinterOrLatentLoad)
  }

  public static func airToAir(type: EquipmentType, compressor: CompressorType, climate: ClimateType)
    -> Self
  {
    .airToAir(.init(type: type, compressor: compressor, climate: climate))
  }

  /// Represents a human readable representation of the system type.
  public var label: String {
    switch self {
    case .heatingOnly(.furnace):
      return "Furnace Heating Only"
    case .heatingOnly(.boiler):
      return "Boiler Heating Only"
    case .heatingOnly(.electric):
      return "Electric Heating Only"
    case let .airToAir(airToAir):
      return
        "Air-Air, \(airToAir.type.description), \(airToAir.compressor.description), \(airToAir.climate.description)"
    }
  }

  /// Represents a ``SystemType/Tag`` for the given system type.
  public var tag: Tag { .init(systemType: self) }

  public struct AirToAir: Codable, Equatable, Sendable {
    public var type: EquipmentType
    public var compressor: CompressorType
    public var climate: ClimateType

    public init(
      type: EquipmentType,
      compressor: CompressorType,
      climate: ClimateType
    ) {
      self.type = type
      self.compressor = compressor
      self.climate = climate
    }
  }

  public enum HeatingOnly: String, Codable, Equatable, Sendable {
    case boiler
    case electric
    case furnace
  }

}

extension SystemType {

  public enum ClimateType: String, Codable, Equatable, CaseIterable, CustomStringConvertible,
    Sendable
  {
    case mildWinterOrLatentLoad
    case coldWinterOrNoLatentLoad

    public var description: String {
      switch self {
      case .mildWinterOrLatentLoad: return "Mild Winter or Latent Load"
      case .coldWinterOrNoLatentLoad: return "Cold Winter or No Latent Load"
      }
    }
  }

  public enum CompressorType: String, Codable, Equatable, CaseIterable, CustomStringConvertible,
    Sendable
  {
    case singleSpeed
    case multiSpeed
    case variableSpeed

    public var description: String {
      switch self {
      case .singleSpeed: return "Single Speed Compressor"
      case .multiSpeed: return "Multi Speed Compressor"
      case .variableSpeed: return "Variable Speed Compressor"
      }
    }
  }

  public enum EquipmentType: String, Codable, Equatable, CaseIterable, CustomStringConvertible,
    Sendable
  {
    case airConditioner
    case heatPump

    public var description: String {
      switch self {
      case .airConditioner: return "Air Conditioner"
      case .heatPump: return "Heat Pump"
      }
    }
  }

  public enum Tag: Int, CaseIterable, Sendable {
    case airCoolingOnlySingleSpeedMildWinter
    case airHeatPumpSingleSpeedMildWinter
    case airCoolingOnlyMultiSpeedMildWinter
    case airHeatPumpMultiSpeedMildWinter
    case airCoolingOnlyVariableSpeedMildWinter
    case airHeatPumpVariableSpeedMildWinter
    case airCoolingOnlySingleSpeedColdWinter
    case airHeatPumpOnlySingleSpeedColdWinter
    case airCoolingOnlyMultiSpeedColdWinter
    case airHeatPumpMultiSpeedColdWinter
    case airCoolingOnlyVariableSpeedColdWinter
    case airHeatPumpVariableSpeedColdWinter
    case furnaceOnly
    case boilerOnly
    case electricOnly

    public var systemType: SystemType {
      switch self {
      case .airCoolingOnlySingleSpeedMildWinter:
        return .airToAir(
          type: .airConditioner, compressor: .singleSpeed, climate: .mildWinterOrLatentLoad)
      case .airHeatPumpSingleSpeedMildWinter:
        return .airToAir(
          type: .heatPump, compressor: .singleSpeed, climate: .mildWinterOrLatentLoad)
      case .airCoolingOnlyMultiSpeedMildWinter:
        return .airToAir(
          type: .airConditioner, compressor: .multiSpeed, climate: .mildWinterOrLatentLoad)
      case .airHeatPumpMultiSpeedMildWinter:
        return .airToAir(type: .heatPump, compressor: .multiSpeed, climate: .mildWinterOrLatentLoad)
      case .airCoolingOnlyVariableSpeedMildWinter:
        return .airToAir(
          type: .airConditioner, compressor: .variableSpeed, climate: .mildWinterOrLatentLoad)
      case .airHeatPumpVariableSpeedMildWinter:
        return .airToAir(
          type: .heatPump, compressor: .variableSpeed, climate: .mildWinterOrLatentLoad)
      case .airCoolingOnlySingleSpeedColdWinter:
        return .airToAir(
          type: .airConditioner, compressor: .singleSpeed, climate: .coldWinterOrNoLatentLoad)
      case .airHeatPumpOnlySingleSpeedColdWinter:
        return .airToAir(
          type: .heatPump, compressor: .singleSpeed, climate: .coldWinterOrNoLatentLoad)
      case .airCoolingOnlyMultiSpeedColdWinter:
        return .airToAir(
          type: .airConditioner, compressor: .multiSpeed, climate: .coldWinterOrNoLatentLoad)
      case .airHeatPumpMultiSpeedColdWinter:
        return .airToAir(
          type: .heatPump, compressor: .multiSpeed, climate: .coldWinterOrNoLatentLoad)
      case .airCoolingOnlyVariableSpeedColdWinter:
        return .airToAir(
          type: .airConditioner, compressor: .variableSpeed, climate: .coldWinterOrNoLatentLoad)
      case .airHeatPumpVariableSpeedColdWinter:
        return .airToAir(
          type: .heatPump, compressor: .variableSpeed, climate: .coldWinterOrNoLatentLoad)
      case .furnaceOnly:
        return .furnaceOnly
      case .boilerOnly:
        return .boilerOnly
      case .electricOnly:
        return .electricOnly
      }
    }

    public var label: String { systemType.label }

    public static let `default` = Self.airHeatPumpVariableSpeedMildWinter

  }
}

extension SystemType.Tag {

  @inlinable
  init(systemType: SystemType) {
    switch systemType {
    case let .airToAir(airToAir):

      let type = airToAir.type
      let compressor = airToAir.compressor
      let climate = airToAir.climate

      if case .airConditioner = type,
        case .singleSpeed = compressor,
        case .mildWinterOrLatentLoad = climate
      {
        self = .airCoolingOnlySingleSpeedMildWinter
      } else if case .airConditioner = type,
        case .singleSpeed = compressor,
        case .coldWinterOrNoLatentLoad = climate
      {
        self = .airCoolingOnlySingleSpeedColdWinter
      } else if case .airConditioner = type,
        case .multiSpeed = compressor,
        case .mildWinterOrLatentLoad = climate
      {
        self = .airCoolingOnlyMultiSpeedMildWinter
      } else if case .airConditioner = type,
        case .multiSpeed = compressor,
        case .coldWinterOrNoLatentLoad = climate
      {
        self = .airCoolingOnlyMultiSpeedColdWinter
      } else if case .airConditioner = type,
        case .variableSpeed = compressor,
        case .mildWinterOrLatentLoad = climate
      {
        self = .airCoolingOnlyVariableSpeedMildWinter
      } else if case .airConditioner = type,
        case .variableSpeed = compressor,
        case .coldWinterOrNoLatentLoad = climate
      {
        self = .airCoolingOnlyVariableSpeedColdWinter
      }
      // Heat Pumps
      else if case .heatPump = type,
        case .singleSpeed = compressor,
        case .mildWinterOrLatentLoad = climate
      {
        self = .airHeatPumpSingleSpeedMildWinter
      } else if case .heatPump = type,
        case .singleSpeed = compressor,
        case .coldWinterOrNoLatentLoad = climate
      {
        self = .airHeatPumpOnlySingleSpeedColdWinter
      } else if case .heatPump = type,
        case .multiSpeed = compressor,
        case .mildWinterOrLatentLoad = climate
      {
        self = .airHeatPumpMultiSpeedMildWinter
      } else if case .heatPump = type,
        case .multiSpeed = compressor,
        case .coldWinterOrNoLatentLoad = climate
      {
        self = .airHeatPumpMultiSpeedColdWinter
      } else if case .heatPump = type,
        case .variableSpeed = compressor,
        case .coldWinterOrNoLatentLoad = climate
      {
        self = .airHeatPumpVariableSpeedColdWinter
      } else {
        self = .airHeatPumpVariableSpeedMildWinter
      }
    case .heatingOnly(.furnace):
      self = .furnaceOnly
    case .heatingOnly(.boiler):
      self = .boilerOnly
    case .heatingOnly(.electric):
      self = .electricOnly
    }
  }
}

// MARK: - Coding
extension SystemType {

  private enum CodingKeys: CodingKey {
    case airToAir
    case heatingOnly
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .airToAir(airToAir):
      try container.encode(airToAir, forKey: .airToAir)
    case .heatingOnly(.boiler):
      try container.encode("boiler", forKey: .heatingOnly)
    case .heatingOnly(.furnace):
      try container.encode("furnace", forKey: .heatingOnly)
    case .heatingOnly(.electric):
      try container.encode("electric", forKey: .heatingOnly)
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let airToAir = try? container.decode(AirToAir.self, forKey: .airToAir) {
      self = .airToAir(airToAir)
      return
    } else if let heating = try? container.decode(HeatingOnly.self, forKey: .heatingOnly) {
      self = .heatingOnly(heating)
      return
    }
    throw DecodingError()
  }
}
