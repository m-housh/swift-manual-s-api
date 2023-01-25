import Models
import XCTestDynamicOverlay

public struct ManualSClient {
  
  public var derating: (DeratingRequest) async throws -> AdjustmentMultiplier
//  public var heatingInterpolation: (HeatingInterpolation) async throws -> HeatingInterpolation.Result
  public var interpolate: (InterpolationRequest) async throws -> InterpolationResult
  public var requiredKW: (RequiredKWRequest) async throws -> Double
  public var sizingLimits: (SystemType, HouseLoad?) async throws -> SizingLimits
  
  @inlinable
  public init(
    derating: @escaping (DeratingRequest) async throws -> AdjustmentMultiplier,
//    heatingInterpolation: @escaping (HeatingInterpolation) async throws -> HeatingInterpolation.Result,
    interpolate: @escaping (InterpolationRequest) async throws -> InterpolationResult,
    requiredKW: @escaping (RequiredKWRequest) async throws -> Double,
    sizingLimits: @escaping (SystemType, HouseLoad?) async throws -> SizingLimits
  ) {
    self.derating = derating
//    self.heatingInterpolation = heatingInterpolation
    self.interpolate = interpolate
    self.requiredKW = requiredKW
    self.sizingLimits = sizingLimits
  }
  
  @inlinable
  public func sizingLimits(systemType: SystemType, houseLoad: HouseLoad? = nil) async throws -> SizingLimits {
    try await self.sizingLimits(systemType, houseLoad)
  }
  
//  @inlinable
//  public func interpolate(_ request: InterpolationRequest) async throws -> InterpolationResult {
//    try await self.interpolate(self, request)
//  }
  
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
  
//  public struct InterpolationResult: Codable, Equatable, Sendable {
//    public let request: InterpolationRequest
//    public let altitudeDeratings: DeratingMultiplier
//    public let capacityAtDesign: CoolingCapacity
//  }
  
//  public enum InterpolationRequest: Codable, Equatable, Sendable {
//    case none(NoInterpolation)
//
//    public struct CoolingCapacityEnvelope: Codable, Equatable, Sendable {
//      public var cfm: Int
//      public var indoorTemperature: Int
//      public var indoorWetBulb: Int
//      public var outdoorTemperature: Int
//      public var capacity: CoolingCapacity
//
//      public init(
//        cfm: Int,
//        indoorTemperature: Int,
//        indoorWetBulb: Int,
//        outdoorTemperature: Int,
//        capacity: CoolingCapacity
//      ) {
//        self.cfm = cfm
//        self.indoorTemperature = indoorTemperature
//        self.indoorWetBulb = indoorWetBulb
//        self.outdoorTemperature = outdoorTemperature
//        self.capacity = capacity
//      }
//    }
//
//    public struct NoInterpolation: Codable, Equatable, Sendable {
//      public var capacity: CoolingCapacityEnvelope
//      public var designInfo: DesignInfo
//      public var houseLoad: HouseLoad
//      public var manufacturerAdjustments: DeratingMultiplier?
//      public var systemType: SystemType
//
//      public init(
//        capacity: CoolingCapacityEnvelope,
//        designInfo: DesignInfo,
//        houseLoad: HouseLoad,
//        manufacturerAdjustments: DeratingMultiplier?,
//        systemType: SystemType
//      ) {
//        self.capacity = capacity
//        self.designInfo = designInfo
//        self.houseLoad = houseLoad
//        self.manufacturerAdjustments = manufacturerAdjustments
//        self.systemType = systemType
//      }
//    }
//  }
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
