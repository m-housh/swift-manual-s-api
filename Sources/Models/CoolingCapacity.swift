
public struct CoolingCapacity: Codable, Equatable, Sendable {
  
  /// The total cooling load / gain.
  public var total: Int
  
  /// The sensible cooling load / gain.
  public var sensible: Int
  
  public init(
    total: Int,
    sensible: Int
  ) {
    self.total = total
    self.sensible = sensible
  }
  
  /// The latent cooling load / gain.
  public var latent: Int { total - sensible }
  
  /// The calculated sensible heat ratio.
  public var sensibleHeatRatio: Double {
    guard total > 0, sensible > 0 else { return 0 }
    return Double(sensible) / Double(total)
  }
  
  /// Creates a cooling load with the values set to zero.
  public static var zero: Self {
    .init(total: 0, sensible: 0)
  }
  
}