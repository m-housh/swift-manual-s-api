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
    case electric(Int = 175)

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
    case electric(Int = 90)

    /// Hold the undersizing limit for a gas / propane furnace system.
    case furnace(Int = 90)
  }
}

// MARK: Encoding
extension SizingLimits.Oversizing {
  
  private enum CodingKeys: CodingKey {
    case boiler
    case cooling
    case electric
    case furnace
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .boiler(boiler):
      try container.encode(boiler, forKey: .boiler)
    case let .cooling(total: total, latent: latent):
      try container.encode(["total": total, "latent": latent], forKey: .cooling)
    case let .electric(electric):
      try container.encode(electric, forKey: .electric)
    case let .furnace(furnace):
      try container.encode(furnace, forKey: .furnace)
    }
  }
}

extension SizingLimits.Undersizing {
  
  private enum CodingKeys: CodingKey {
    case boiler
    case cooling
    case electric
    case furnace
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .boiler(boiler):
      try container.encode(boiler, forKey: .boiler)
    case let .cooling(total: total, sensible: sensible, latent: latent):
      try container.encode(["total": total, "sensible": sensible, "latent": latent], forKey: .cooling)
    case let .electric(electric):
      try container.encode(electric, forKey: .electric)
    case let .furnace(furnace):
      try container.encode(furnace, forKey: .furnace)
    }
  }
}
