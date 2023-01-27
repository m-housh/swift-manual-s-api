import Models
import XCTestDynamicOverlay

public struct UtilsClient {
  public var balancePoint: @Sendable (BalancePointRequest) async throws -> BalancePointResponse
  public var derating: @Sendable (DeratingRequest) async throws -> AdjustmentMultiplier
  public var requiredKW: @Sendable (RequiredKWRequest) async throws -> RequiredKWResponse
  public var sizingLimits: @Sendable (SizingLimitRequest) async throws -> SizingLimits
  
  public init(
    balancePoint: @escaping @Sendable (BalancePointRequest) async throws -> BalancePointResponse,
    derating: @escaping @Sendable (DeratingRequest) async throws -> AdjustmentMultiplier,
    requiredKW: @escaping @Sendable (RequiredKWRequest) async throws -> RequiredKWResponse,
    sizingLimits: @escaping @Sendable (SizingLimitRequest) async throws -> SizingLimits
  ) {
    self.balancePoint = balancePoint
    self.derating = derating
    self.requiredKW = requiredKW
    self.sizingLimits = sizingLimits
  }
}

// MARK: - Requests
extension UtilsClient {
  
  public enum BalancePointRequest: Codable, Equatable, Sendable {
    case thermal(ThermalBalancePointRequest)
//    case economic
    
    public struct ThermalBalancePointRequest: Codable, Equatable, Sendable {
      public var heatLoss: Double
      public var heatPumpCapacity: HeatPumpCapacity
      public var winterDesignTemperature: Double
      
      public init(
        heatLoss: Double,
        heatPumpCapacity: HeatPumpCapacity,
        winterDesignTemperature: Double
      ) {
        self.heatLoss = heatLoss
        self.heatPumpCapacity = heatPumpCapacity
        self.winterDesignTemperature = winterDesignTemperature
      }
    }
    
//    public enum EconomicBalancePointRequest: Codable, Equatable, Sendable {
//      case naturalGas
//
//      public struct NaturalGasRequest: Codable, Equatable, Sendable {
//        public let c
//      }
//    }
  }
  
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
  
  public struct BalancePointResponse: Codable, Equatable, Sendable {
    public let balancePoint: Double
    
    public init(balancePoint: Double) {
      self.balancePoint = balancePoint
    }
  }
  
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
    balancePoint: unimplemented("\(Self.self).balancePoint"),
    derating: unimplemented("\(Self.self).derating"),
    requiredKW: unimplemented("\(Self.self).requiredKW"),
    sizingLimits: unimplemented("\(Self.self).sizingLimits")
  )
}
