/// A container for heat-pump heating capacities.
public struct HeatPumpCapacity: Codable, Equatable, Sendable {

  /// The capacity at 47° outdoor temperature.
  public var at47: Int

  /// The capacity at 17° outdoor temperature.
  public var at17: Int

  /// Create a new heat pump capacity container.
  ///
  /// - Parameters:
  ///   - at47: The capacity at 47° outdoor temperature.
  ///   - at17: The capacity at 17° outdoor temperature.
  public init(at47: Int, at17: Int) {
    self.at47 = at47
    self.at17 = at17
  }

}
