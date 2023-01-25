
public enum DeratingMultiplier: Codable, Equatable, Sendable {
  case airToAir(total: Double, sensible: Double, heating: Double)
  case heating(Double)
}
