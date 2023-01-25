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
extension ManualSClient.HeatingInterpolation {
  
  public struct BoilerRequest: Codable, Equatable, Sendable {
    public var altitudeDeratings: DeratingMultiplier?
    public var houseLoad: HouseLoad
    public var input: Int
    public var afue: Double
    
    public init(
      altitudeDeratings: DeratingMultiplier? = nil,
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
    public var altitudeDeratings: DeratingMultiplier?
    public var capacity: HeatPumpCapacity?
    public var houseLoad: HouseLoad
    public var inputKW: Double
    
    public init(
      altitudeDeratings: DeratingMultiplier? = nil,
      capacity: HeatPumpCapacity? = nil,
      houseLoad: HouseLoad,
      inputKW: Double
    ) {
      self.altitudeDeratings = altitudeDeratings
      self.capacity = capacity
      self.houseLoad = houseLoad
      self.inputKW = inputKW
    }
  }
  
  public struct FurnaceRequest: Codable, Equatable, Sendable {
    public var altitudeDeratings: DeratingMultiplier?
    public var houseLoad: HouseLoad
    public var input: Int
    public var afue: Double
    
    public init(
      altitudeDeratings: DeratingMultiplier? = nil,
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
    public var altitudeDeratings: DeratingMultiplier?
    public var capacity: HeatPumpCapacity
    public var houseLoad: HouseLoad
    
    public init(
      altitudeDeratings: DeratingMultiplier? = nil,
      capacity: HeatPumpCapacity,
      houseLoad: HouseLoad
    ) {
      self.altitudeDeratings = altitudeDeratings
      self.capacity = capacity
      self.houseLoad = houseLoad
    }
  }
}

// MARK: - Results
extension ManualSClient.HeatingInterpolation {
  
  public enum Result: Codable, Equatable, Sendable {
    case boiler(BoilerResult)
    case electric
    case furnace(FurnaceResult)
    case heatPump
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
}
