

public enum InterpolationResponse: Codable, Equatable, Sendable {
  case cooling(Cooling)
  case heating(Heating)
  
  public struct Cooling: Codable, Equatable, Sendable {
    public let result: Result
    
    public init(result: Result) {
      self.result = result
    }
    
    public struct Result: Codable, Equatable, Sendable {
      public let interpolatedCapacity: CoolingCapacity
      public let excessLatent: Int
      public let finalCapacityAtDesign: CoolingCapacity
      public let altitudeDerating: AdjustmentMultiplier?
      public let capacityAsPercentOfLoad: CapacityAsPercentOfLoad
      
      public init(
        interpolatedCapacity: CoolingCapacity,
        excessLatent: Int,
        finalCapacityAtDesign: CoolingCapacity,
        altitudeDerating: AdjustmentMultiplier?,
        capacityAsPercentOfLoad: CapacityAsPercentOfLoad
      ) {
        self.interpolatedCapacity = interpolatedCapacity
        self.excessLatent = excessLatent
        self.finalCapacityAtDesign = finalCapacityAtDesign
        self.altitudeDerating = altitudeDerating
        self.capacityAsPercentOfLoad = capacityAsPercentOfLoad
      }
    }
  }
  
  public struct Heating: Codable, Equatable, Sendable {
    
    public let result: Result
    
    public init(result: Result) {
      self.result = result
    }
    
    public enum Result: Codable, Equatable, Sendable {
      case boiler(Boiler)
      case electric(Electric)
      case furnace(Furnace)
      case heatPump(HeatPump)
      
      public struct Boiler: Codable, Equatable, Sendable {
        public let outputCapacity: Int
        public let finalCapacity: Int
        public let percentOfLoad: Double
        
        public init(
          outputCapacity: Int,
          finalCapacity: Int,
          percentOfLoad: Double
        ) {
          self.outputCapacity = outputCapacity
          self.finalCapacity = finalCapacity
          self.percentOfLoad = percentOfLoad
        }
      }
      
      public struct Furnace: Codable, Equatable, Sendable {
        public let outputCapacity: Int
        public let finalCapacity: Int
        public let percentOfLoad: Double
        
        public init(
          outputCapacity: Int,
          finalCapacity: Int,
          percentOfLoad: Double
        ) {
          self.outputCapacity = outputCapacity
          self.finalCapacity = finalCapacity
          self.percentOfLoad = percentOfLoad
        }
      }
      
      public struct Electric: Codable, Equatable, Sendable {
        public let requiredKW: Double
        public let percentOfLoad: Double
        
        public init(
          requiredKW: Double,
          percentOfLoad: Double
        ) {
          self.requiredKW = requiredKW
          self.percentOfLoad = percentOfLoad
        }
      }
      
      public struct HeatPump: Codable, Equatable, Sendable {
        public let finalCapacity: HeatPumpCapacity
        public let capacityAtDesign: Int
        public let balancePointTemperature: Double
        public let requiredKW: Double
        
        public init(
          finalCapacity: HeatPumpCapacity,
          capacityAtDesign: Int,
          balancePointTemperature: Double,
          requiredKW: Double
        ) {
          self.finalCapacity = finalCapacity
          self.capacityAtDesign = capacityAtDesign
          self.balancePointTemperature = balancePointTemperature
          self.requiredKW = requiredKW
        }
      }
    }
  }
}