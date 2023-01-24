import Models

public struct NoInterpolationRequest: Codable, Equatable, Sendable {
  
  public let designInfo: DesignInfo
  public let houseLoad: HouseLoad
  public let systemType: SystemType
  
}

extension NoInterpolationRequest {
  
  public struct Capacity: Codable, Equatable, Sendable {
    public var outdoorDryBulb: Int
    public var indoorDryBulb: Int
    public var designCFM: Int
  }
}
