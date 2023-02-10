/// Represents adjustment multiplers, that are used in several contexts.
///
/// Generally these are either applied to manufacturer's capacity containers or from an altitude
/// derating.
public enum AdjustmentMultiplier: Codable, Equatable, Sendable {
  
  /// Multiplers for system types that have an air-conditioner or heat-pump.
  case airToAir(total: Double, sensible: Double, heating: Double)
  
  /// A multiplier for heating only system types.
  case heating(multiplier: Double)
}
