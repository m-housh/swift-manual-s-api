import Models
import XCTestDynamicOverlay

public struct UtilsClient {
  public var derating: (DeratingRequest) async throws -> AdjustmentMultiplier
  public var requiredKW: (RequiredKWRequest) async throws -> RequiredKWResponse
  public var sizingLimits: (SizingLimitRequest) async throws -> SizingLimits
  
  public init(
    derating: @escaping (DeratingRequest) async throws -> AdjustmentMultiplier,
    requiredKW: @escaping (RequiredKWRequest) async throws -> RequiredKWResponse,
    sizingLimits: @escaping (SizingLimitRequest) async throws -> SizingLimits
  ) {
    self.derating = derating
    self.requiredKW = requiredKW
    self.sizingLimits = sizingLimits
  }
}

// MARK: - Requests
extension UtilsClient {
  
  public struct DeratingRequest: Codable, Equatable, Sendable {
    public var systemType: SystemType
    public var elevation: Int
    
    public init(systemType: SystemType, elevation: Int) {
      self.systemType = systemType
      self.elevation = elevation
    }
  }
  
  public struct SizingLimitRequest: Codable, Equatable, Sendable {
    public var systemType: SystemType
    public var houseLoad: HouseLoad?
    
    public init(systemType: SystemType, houseLoad: HouseLoad? = nil) {
      self.systemType = systemType
      self.houseLoad = houseLoad
    }
  }
  
  public struct RequiredKWRequest: Codable, Equatable, Sendable {
    public var houseLoad: HouseLoad
    public var capacityAtDesign: Int
    
    public init(
      houseLoad: HouseLoad,
      capacityAtDesign: Int = 0
    ) {
      self.houseLoad = houseLoad
      self.capacityAtDesign = capacityAtDesign
    }
  }
}

// MARK: - Responses
extension UtilsClient {
  
  public struct RequiredKWResponse: Codable, Equatable, Sendable {
    public let requiredKW: Double
    
    public init(requiredKW: Double) {
      self.requiredKW = requiredKW
    }
  }
}

// MARK: - Unimplemented
extension UtilsClient {
  
  public static let failing = Self.init(
    derating: unimplemented("\(Self.self).derating"),
    requiredKW: unimplemented("\(Self.self).requiredKW"),
    sizingLimits: unimplemented("\(Self.self).sizingLimits")
  )
}
