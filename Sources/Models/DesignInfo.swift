/// Represents the design information required for Manual-S.
public struct DesignInfo: Codable, Equatable, Sendable {
  
  /// The summer design information.
  public var summer: Summer
  
  /// The winter design information.
  public var winter: Winter
  
  /// The project / house elevation.
  public var elevation: Int
  
  public init(
    summer: Summer = .init(),
    winter: Winter = .init(),
    elevation: Int = 0
  ) {
    self.summer = summer
    self.winter = winter
    self.elevation = elevation
  }
  
  /// Represents the design information for the summer conditions.
  public struct Summer: Codable, Equatable, Sendable{
    public var outdoorTemperature: Int
    public var indoorTemperature: Int
    public var indoorHumidity: Int
    
    public init(
      outdoorTemperature: Int = 90,
      indoorTemperature: Int = 75,
      indoorHumidity: Int = 50
    ) {
      self.outdoorTemperature = outdoorTemperature
      self.indoorTemperature  = indoorTemperature
      self.indoorHumidity = indoorHumidity
    }
  }
  
  /// Represents the design information for the winter conditions.
  public struct Winter: Codable, Equatable, Sendable {
    public var outdoorTemperature: Int
    
    public init(outdoorTemperature: Int = 5) {
      self.outdoorTemperature = outdoorTemperature
    }
  }
}

extension DesignInfo {
  
  public static let zero = Self.init(
    summer: .init(outdoorTemperature: 0, indoorTemperature: 0, indoorHumidity: 0),
    winter: .init(outdoorTemperature: 0),
    elevation: 0
  )
  
  #if DEBUG
  public static let mock = Self.init()
  #endif
}
