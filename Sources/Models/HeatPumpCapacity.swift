/// A container for heat-pump heating capacities.
public struct HeatPumpCapacity: Codable, Equatable, Sendable {
  
  /// The capacity at 47° outdoor temperature.
  public var at47: Int
  
  /// The capacity at 17° outdoor temperature.
  public var at17: Int
  
  public init(at47: Int, at17: Int) {
    self.at47 = at47
    self.at17 = at17
  }
  
  /// Convenience for heat-pump capacity initialized at zero.
  public static let zero = Self.init(at47: 0, at17: 0)
  
  #if DEBUG
  /// Convenience for a mock value, used in views and tests.
  public static let mock = Self.init(at47: 24_600, at17: 15_100)
  #endif
}
