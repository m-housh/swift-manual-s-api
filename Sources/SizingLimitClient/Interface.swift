import Models
import XCTestDynamicOverlay

public struct SizingLimitClient {
  public var sizingLimits: (Request.SizingLimits) async throws -> SizingLimits
 
  public init(
    sizingLimits: @Sendable @escaping (Request.SizingLimits) async throws -> SizingLimits
  ) {
    self.sizingLimits = sizingLimits
  }
}

extension SizingLimitClient {
  
  public enum Request {
    
    public struct SizingLimits: Codable, Equatable, Sendable {
      public let houseLoad: HouseLoad?
      public let systemType: SystemType
      
      public init(
        systemType: SystemType,
        houseLoad: HouseLoad? = nil
      ) {
        self.houseLoad = houseLoad
        self.systemType = systemType
      }
    }
  }
  
  public struct SizingLimits: Codable, Equatable, Sendable {
    
    public let oversizing: Oversizing
    public let undersizing: Undersizing
    
    public init(oversizing: Oversizing, undersizing: Undersizing) {
      self.oversizing = oversizing
      self.undersizing = undersizing
    }
    
    public enum Oversizing: Codable, Equatable, Sendable {
      case cooling(total: Int, latent: Int = 150)
      case furnace(Int = 200)
      case electricFurnace(Int = 175)
    }
    
    public enum Undersizing: Codable, Equatable, Sendable {
      case cooling(total: Int = 90, sensible: Int = 90, latent: Int = 90)
      case furnace(Int = 90)
      case electricFurnace(Int = 90)
    }
  }
}


extension SizingLimitClient {
  
  public static let noop = Self.init(
    sizingLimits: unimplemented("\(Self.self).sizingLimits")
  )
}
