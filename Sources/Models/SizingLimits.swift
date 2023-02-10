/// Represents the over sizing and undersizing limits.
///
public struct SizingLimits: Codable, Equatable, Sendable {

  /// The oversizing limits.
  public let oversizing: Oversizing
  
  /// The undersizing limits.
  public let undersizing: Undersizing

  /// Create a new sizing limits container.
  ///
  /// - Parameters:
  ///   - oversizing: The oversizing limits.
  ///   - undersizing: The undersizing limits.
  public init(oversizing: Oversizing, undersizing: Undersizing) {
    self.oversizing = oversizing
    self.undersizing = undersizing
  }

  /// Represents the oversizing limits for different system types.
  public enum Oversizing: Codable, Equatable, Sendable {
    
    /// Hold the oversizing limit for a boiler system.
    case boiler(Int = 140)
    
    /// Hold the oversizing limit for a cooling system.
    case cooling(total: Int, latent: Int = 150)
    
    /// Hold the oversizing limit for an electric furnace system.
    case electricFurnace(Int = 175)
    
    /// Hold the oversizing limit for a gas / propane furnace system.
    case furnace(Int = 140)
  }
  
  /// Represents the undersizing limits for different system types.
  public enum Undersizing: Codable, Equatable, Sendable {
    
    /// Hold the undersizing limit for a boiler system.
    case boiler(Int = 90)
    
    /// Hold the undersizing limits for a cooling system.
    case cooling(total: Int = 90, sensible: Int = 90, latent: Int = 90)
    
    /// Hold the undersizing limit for an electric furnace system.
    case electricFurnace(Int = 90)
    
    /// Hold the undersizing limit for a gas / propane furnace system.
    case furnace(Int = 90)
  }
}
