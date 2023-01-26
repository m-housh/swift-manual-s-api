import Models
import XCTestDynamicOverlay

public struct ManualSClient {
  
  public var derating: (DeratingRequest) async throws -> AdjustmentMultiplier
  public var interpolate: (InterpolationRequest) async throws -> InterpolationResult
  public var requiredKW: (RequiredKWRequest) async throws -> Double
  public var sizingLimits: (SystemType, HouseLoad?) async throws -> SizingLimits
  
  @inlinable
  public init(
    derating: @escaping (DeratingRequest) async throws -> AdjustmentMultiplier,
    interpolate: @escaping (InterpolationRequest) async throws -> InterpolationResult,
    requiredKW: @escaping (RequiredKWRequest) async throws -> Double,
    sizingLimits: @escaping (SystemType, HouseLoad?) async throws -> SizingLimits
  ) {
    self.derating = derating
    self.interpolate = interpolate
    self.requiredKW = requiredKW
    self.sizingLimits = sizingLimits
  }
  
  @inlinable
  public func sizingLimits(systemType: SystemType, houseLoad: HouseLoad? = nil) async throws -> SizingLimits {
    try await self.sizingLimits(systemType, houseLoad)
  }
 
  @inlinable
  public func requiredKW(
    houseLoad: HouseLoad,
    capacityAtDesign: Int = 0
  ) async throws -> Double {
    try await self.requiredKW(.init(houseLoad: houseLoad, capacityAtDesign: capacityAtDesign))
  }
  
}

extension ManualSClient {
  
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
  
  public enum DeratingRequest {
    case elevation(system: SystemType, elevation: Int)
  }
  
  public enum InterpolationRequest: Codable, Equatable, Sendable {
    case cooling(CoolingInterpolation)
    case heating(HeatingInterpolation)
  }
  
  public enum InterpolationResult: Codable, Equatable, Sendable {
    case cooling(CoolingInterpolation.Result)
    case heating(HeatingInterpolation.Result)
  }
}

extension ManualSClient {
  public static let noop = Self.init(
    derating: unimplemented("\(Self.self).derating"),
//    heatingInterpolation: unimplemented("\(Self.self).heatingInterpolation"),
    interpolate: unimplemented("\(Self.self).interpolate"),
    requiredKW: unimplemented("\(Self.self).requiredKW"),
    sizingLimits: unimplemented("\(Self.self).sizingLimits")
  )
}
