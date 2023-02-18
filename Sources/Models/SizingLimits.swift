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
    case cooling(Cooling)

    /// Hold the oversizing limit for an electric furnace system.
    case electric(Int = 175)

    /// Hold the oversizing limit for a gas / propane furnace system.
    case furnace(Int = 140)
    
    public static func cooling(total: Int, latent: Int = 150) -> Self {
      .cooling(.init(total: total, latent: latent))
    }
    
    public struct Cooling: Codable, Equatable, Sendable {
      public var total: Int
      public var latent: Int
      
      public init(
        total: Int,
        latent: Int = 150
      ) {
        self.total = total
        self.latent = latent
      }
    }
  }

  /// Represents the undersizing limits for different system types.
  public enum Undersizing: Codable, Equatable, Sendable {

    /// Hold the undersizing limit for a boiler system.
    case boiler(Int = 90)

    /// Hold the undersizing limits for a cooling system.
    case cooling(Cooling)

    /// Hold the undersizing limit for an electric furnace system.
    case electric(Int = 90)

    /// Hold the undersizing limit for a gas / propane furnace system.
    case furnace(Int = 90)
    
    public static func cooling(
      total: Int = 90,
      sensible: Int = 90,
      latent: Int = 90
    ) -> Self {
      .cooling(.init(total: total, sensible: sensible, latent: latent))
    }
    
    public struct Cooling: Codable, Equatable, Sendable {
      public var total: Int
      public var sensible: Int
      public var latent: Int
      
      public init(
        total: Int = 90,
        sensible: Int = 90,
        latent: Int = 90
      ) {
        self.total = total
        self.sensible = sensible
        self.latent = latent
      }
    }
  }
}

// MARK: Coding
struct DecodingError: Error { }

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
    case let .cooling(cooling):
      try container.encode(cooling, forKey: .cooling)
    case let .electric(electric):
      try container.encode(electric, forKey: .electric)
    case let .furnace(furnace):
      try container.encode(furnace, forKey: .furnace)
    }
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let boiler = try? container.decode(Int.self, forKey: .boiler) {
      self = .boiler(boiler)
      return
    } else if let cooling = try? container.decode(Cooling.self, forKey: .cooling) {
      self = .cooling(cooling)
      return
    } else if let electric = try? container.decode(Int.self, forKey: .electric) {
      self = .electric(electric)
      return
    } else if let furnace = try? container.decode(Int.self, forKey: .furnace) {
      self = .furnace(furnace)
      return
    }
    throw DecodingError()
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
    case let .cooling(cooling):
      try container.encode(cooling, forKey: .cooling)
    case let .electric(electric):
      try container.encode(electric, forKey: .electric)
    case let .furnace(furnace):
      try container.encode(furnace, forKey: .furnace)
    }
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let boiler = try? container.decode(Int.self, forKey: .boiler) {
      self = .boiler(boiler)
      return
    } else if let cooling = try? container.decode(Cooling.self, forKey: .cooling) {
      self = .cooling(cooling)
      return
    } else if let electric = try? container.decode(Int.self, forKey: .electric) {
      self = .electric(electric)
      return
    } else if let furnace = try? container.decode(Int.self, forKey: .furnace) {
      self = .furnace(furnace)
      return
    }
    throw DecodingError()
  }
  
}
