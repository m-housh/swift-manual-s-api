import Models

extension ManualSClient {
  
  public enum HeatingInterpolation: Codable, Equatable, Sendable {
    
    case boiler(BoilerRequest)
    case electric(ElectricRequest)
    case furnace(FurnaceRequest)
    case heatPump(HeatPumpRequest)
    
  }
}

// MARK: - Requests

// TODO: Remove altitude deratings and figure those out by designInfo instead.
extension ManualSClient.HeatingInterpolation {
  
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

// MARK: - Results
extension ManualSClient.HeatingInterpolation {
  
  public enum Result: Codable, Equatable, Sendable {
    case boiler(BoilerResult)
    case electric(ElectricResult)
    case furnace(FurnaceResult)
    case heatPump(HeatPumpResult)
  }
  
  public struct BoilerResult: Codable, Equatable, Sendable {
    public let request: BoilerRequest
    public let outputCapacity: Int
    public let finalCapacity: Int
    public let percentOfLoad: Double
    
    public init(
      request: BoilerRequest,
      outputCapacity: Int,
      finalCapacity: Int,
      percentOfLoad: Double
    ) {
      self.request = request
      self.outputCapacity = outputCapacity
      self.finalCapacity = finalCapacity
      self.percentOfLoad = percentOfLoad
    }
  }
  
  public struct FurnaceResult: Codable, Equatable, Sendable {
    public let request: FurnaceRequest
    public let outputCapacity: Int
    public let finalCapacity: Int
    public let percentOfLoad: Double
    
    public init(
      request: FurnaceRequest,
      outputCapacity: Int,
      finalCapacity: Int,
      percentOfLoad: Double
    ) {
      self.request = request
      self.outputCapacity = outputCapacity
      self.finalCapacity = finalCapacity
      self.percentOfLoad = percentOfLoad
    }
  }
  
  public struct ElectricResult: Codable, Equatable, Sendable {
    public let request: ElectricRequest
    public let requiredKW: Double
    public let percentOfLoad: Double
    
    public init(
      request: ElectricRequest,
      requiredKW: Double,
      percentOfLoad: Double
    ) {
      self.request = request
      self.requiredKW = requiredKW
      self.percentOfLoad = percentOfLoad
    }
  }
  
  public struct HeatPumpResult: Codable, Equatable, Sendable {
    public let request: HeatPumpRequest
    public let finalCapacity: HeatPumpCapacity
    public let capacityAtDesign: Int
    public let balancePointTemperature: Double
    public let requiredKW: Double
    
    public init(
      request: HeatPumpRequest,
      finalCapacity: HeatPumpCapacity,
      capacityAtDesign: Int,
      balancePointTemperature: Double,
      requiredKW: Double
    ) {
      self.request = request
      self.finalCapacity = finalCapacity
      self.capacityAtDesign = capacityAtDesign
      self.balancePointTemperature = balancePointTemperature
      self.requiredKW = requiredKW
    }
  }
}
