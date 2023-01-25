import Models
import XCTestDynamicOverlay

public struct ManualSClient {
  
  public var derating: (DeratingRequest) async throws -> DeratingMultiplier
  public var interpolate: (ManualSClient, InterpolationRequest) async throws -> InterpolationResult
  public var sizingLimits: (SystemType, HouseLoad?) async throws -> SizingLimits
  
  @inlinable
  public init(
    derating: @escaping (DeratingRequest) async throws -> DeratingMultiplier,
    interpolate: @escaping (ManualSClient, InterpolationRequest) async throws -> InterpolationResult,
    sizingLimits: @escaping (SystemType, HouseLoad?) async throws -> SizingLimits
  ) {
    self.derating = derating
    self.interpolate = interpolate
    self.sizingLimits = sizingLimits
  }
  
  @inlinable
  public func sizingLimits(systemType: SystemType, houseLoad: HouseLoad? = nil) async throws -> SizingLimits {
    try await self.sizingLimits(systemType, houseLoad)
  }
  
  @inlinable
  public func interpolate(_ request: InterpolationRequest) async throws -> InterpolationResult {
    try await self.interpolate(self, request)
  }
  
}

extension ManualSClient {
  
  public enum DeratingRequest {
    case elevation(system: SystemType, elevation: Int)
  }
  
  public struct InterpolationResult: Codable, Equatable, Sendable {
    public let request: InterpolationRequest
    public let altitudeDeratings: DeratingMultiplier
    public let capacityAtDesign: CoolingCapacity
  }
  
  public enum InterpolationRequest: Codable, Equatable, Sendable {
    case none(NoInterpolation)
    
    public struct CoolingCapacityEnvelope: Codable, Equatable, Sendable {
      public var cfm: Int
      public var indoorTemperature: Int
      public var indoorWetBulb: Int
      public var outdoorTemperature: Int
      public var capacity: CoolingCapacity
      
      public init(
        cfm: Int,
        indoorTemperature: Int,
        indoorWetBulb: Int,
        outdoorTemperature: Int,
        capacity: CoolingCapacity
      ) {
        self.cfm = cfm
        self.indoorTemperature = indoorTemperature
        self.indoorWetBulb = indoorWetBulb
        self.outdoorTemperature = outdoorTemperature
        self.capacity = capacity
      }
    }
    
    public struct NoInterpolation: Codable, Equatable, Sendable {
      public var capacity: CoolingCapacityEnvelope
      public var designInfo: DesignInfo
      public var houseLoad: HouseLoad
      public var manufacturerDerating: DeratingMultiplier?
      public var systemType: SystemType
      
      public init(
        capacity: CoolingCapacityEnvelope,
        designInfo: DesignInfo,
        houseLoad: HouseLoad,
        manufacturerDerating: DeratingMultiplier?,
        systemType: SystemType
      ) {
        self.capacity = capacity
        self.designInfo = designInfo
        self.houseLoad = houseLoad
        self.manufacturerDerating = manufacturerDerating
        self.systemType = systemType
      }
    }
  }
}

extension ManualSClient {
  public static let noop = Self.init(
    derating: unimplemented("\(Self.self).derating"),
    interpolate: unimplemented("\(Self.self).interpolate"),
    sizingLimits: unimplemented("\(Self.self).sizingLimits")
  )
}
