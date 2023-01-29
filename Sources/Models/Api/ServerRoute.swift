import Foundation

public enum ServerRoute: Equatable {
  case api(Api)
  case home
}

extension ServerRoute {
  public struct Api: Equatable {
    public let isDebug: Bool
    public let route: Route
    
    public init(
      isDebug: Bool,
      route: Route
    ) {
      self.isDebug = isDebug
      self.route = route
    }
    
    public enum Route: Equatable {
      case balancePoint(BalancePointRequest)
      case derating(Derating)
      case interpolate(InterpolationRequest)
      case requiredKW(RequiredKW)
      case sizingLimits(SizingLimitRequest)
      
      public enum BalancePointRequest: Codable, Equatable, Sendable {
        case thermal(Thermal)
        
        public struct Thermal: Codable, Equatable, Sendable {
          public var designTemperature: Double
          public var heatLoss: Double
          public var capacity: HeatPumpCapacity
          
          public init(designTemperature: Double, heatLoss: Double, capacity: HeatPumpCapacity) {
            self.designTemperature = designTemperature
            self.heatLoss = heatLoss
            self.capacity = capacity
          }
        }
      }
      
      public struct Derating: Codable, Equatable, Sendable {
        public var elevation: Int
        public var systemType: SystemType
        
        public init(elevation: Int, systemType: SystemType) {
          self.elevation = elevation
          self.systemType = systemType
        }
      }
      
      public struct RequiredKW: Codable, Equatable, Sendable {
        public var capacityAtDesign: Double
        public var heatLoss: Double
        
        public init(capacityAtDesign: Double, heatLoss: Double) {
          self.capacityAtDesign = capacityAtDesign
          self.heatLoss = heatLoss
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
      
      public enum InterpolationRequest: Codable, Equatable, Sendable {
        case cooling(Cooling)
        case heating(Heating)
        
        public enum Cooling: Codable, Equatable, Sendable {
          case noInterpolation(NoInterpolationRequest)
          case oneWayIndoor(OneWayRequest)
          case oneWayOutdoor(OneWayRequest)
          case twoWay(TwoWayRequest)
          
          public struct TwoWayRequest: CoolingInterpolationRequest {
            public var aboveDesign: CapacityEnvelope
            public var belowDesign: CapacityEnvelope
            public var designInfo: DesignInfo
            public var houseLoad: HouseLoad
            public var manufacturerAdjustments: AdjustmentMultiplier?
            public var systemType: SystemType
            
            public init(
              aboveDesign: CapacityEnvelope,
              belowDesign: CapacityEnvelope,
              designInfo: DesignInfo,
              houseLoad: HouseLoad,
              manufacturerAdjustments: AdjustmentMultiplier? = nil,
              systemType: SystemType
            ) {
              self.aboveDesign = aboveDesign
              self.belowDesign = belowDesign
              self.designInfo = designInfo
              self.houseLoad = houseLoad
              self.manufacturerAdjustments = manufacturerAdjustments
              self.systemType = systemType
            }
            
            public struct CapacityEnvelope: Codable, Equatable, Sendable {
              public var above: CoolingCapacityEnvelope
              public var below: CoolingCapacityEnvelope
              
              public init(above: CoolingCapacityEnvelope, below: CoolingCapacityEnvelope) {
                self.above = above
                self.below = below
              }
            }
          }
          
          public struct OneWayRequest: CoolingInterpolationRequest {
            public var aboveDesign: CoolingCapacityEnvelope
            public var belowDesign: CoolingCapacityEnvelope
            public var designInfo: DesignInfo
            public var houseLoad: HouseLoad
            public var manufacturerAdjustments: AdjustmentMultiplier?
            public var systemType: SystemType
            
            public init(
              aboveDesign: CoolingCapacityEnvelope,
              belowDesign: CoolingCapacityEnvelope,
              designInfo: DesignInfo,
              houseLoad: HouseLoad,
              manufacturerAdjustments: AdjustmentMultiplier? = nil,
              systemType: SystemType
            ) {
              self.aboveDesign = aboveDesign
              self.belowDesign = belowDesign
              self.designInfo = designInfo
              self.houseLoad = houseLoad
              self.manufacturerAdjustments = manufacturerAdjustments
              self.systemType = systemType
            }
          }
          
          public struct NoInterpolationRequest: CoolingInterpolationRequest {
            public var capacity: CoolingCapacityEnvelope
            public var designInfo: DesignInfo
            public var houseLoad: HouseLoad
            public var manufacturerAdjustments: AdjustmentMultiplier?
            public var systemType: SystemType
            
            public init(
              capacity: CoolingCapacityEnvelope,
              designInfo: DesignInfo,
              houseLoad: HouseLoad,
              manufacturerAdjustments: AdjustmentMultiplier?,
              systemType: SystemType
            ) {
              self.capacity = capacity
              self.designInfo = designInfo
              self.houseLoad = houseLoad
              self.manufacturerAdjustments = manufacturerAdjustments
              self.systemType = systemType
            }
          }
        }
        
        public enum Heating: Codable, Equatable, Sendable {
          
          case boiler(BoilerRequest)
          case electric(ElectricRequest)
          case furnace(FurnaceRequest)
          case heatPump(HeatPumpRequest)
          
          public struct BoilerRequest: Codable, Equatable, Sendable {
            public var altitudeDeratings: AdjustmentMultiplier?
            public var houseLoad: HouseLoad
            public var input: Int
            public var afue: Double
            
            public init(
              altitudeDeratings: AdjustmentMultiplier? = nil,
              houseLoad: HouseLoad,
              input: Int,
              afue: Double
            ) {
              self.altitudeDeratings = altitudeDeratings
              self.houseLoad = houseLoad
              self.input = input
              self.afue = afue
            }
          }
          
          public struct ElectricRequest: Codable, Equatable, Sendable {
            public var altitudeDeratings: AdjustmentMultiplier?
            public var heatPumpCapacity: Int?
            public var houseLoad: HouseLoad
            public var inputKW: Double
            
            public init(
              altitudeDeratings: AdjustmentMultiplier? = nil,
              heatPumpCapacity: Int? = nil,
              houseLoad: HouseLoad,
              inputKW: Double
            ) {
              self.altitudeDeratings = altitudeDeratings
              self.heatPumpCapacity = heatPumpCapacity
              self.houseLoad = houseLoad
              self.inputKW = inputKW
            }
          }
          
          public struct FurnaceRequest: Codable, Equatable, Sendable {
            public var altitudeDeratings: AdjustmentMultiplier?
            public var houseLoad: HouseLoad
            public var input: Int
            public var afue: Double
            
            public init(
              altitudeDeratings: AdjustmentMultiplier? = nil,
              houseLoad: HouseLoad,
              input: Int,
              afue: Double
            ) {
              self.altitudeDeratings = altitudeDeratings
              self.houseLoad = houseLoad
              self.input = input
              self.afue = afue
            }
          }
          
          public struct HeatPumpRequest: Codable, Equatable, Sendable {
            public var altitudeDeratings: AdjustmentMultiplier?
            public var capacity: HeatPumpCapacity
            public var designInfo: DesignInfo
            public var houseLoad: HouseLoad
            
            public init(
              altitudeDeratings: AdjustmentMultiplier? = nil,
              capacity: HeatPumpCapacity,
              designInfo: DesignInfo,
              houseLoad: HouseLoad
            ) {
              self.altitudeDeratings = altitudeDeratings
              self.capacity = capacity
              self.designInfo = designInfo
              self.houseLoad = houseLoad
            }
          }
        }
      }
    }
  }
}

public protocol CoolingInterpolationRequest: Codable, Equatable, Sendable {
  var designInfo: DesignInfo { get }
  var houseLoad: HouseLoad { get }
  var manufacturerAdjustments: AdjustmentMultiplier? { get }
  var systemType: SystemType { get }
}
