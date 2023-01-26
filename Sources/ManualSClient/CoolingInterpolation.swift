import Models

extension ManualSClient {
  
  public enum CoolingInterpolation: Codable, Equatable, Sendable {
    case noInterpolation(NoInterpolationRequest)
    case oneWayIndoor(OneWayRequest)
    case oneWayOutdoor(OneWayRequest)
    case twoWay(TwoWayRequest)
  }
}

// MARK: - Requests
extension ManualSClient.CoolingInterpolation {
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

public protocol CoolingInterpolationRequest: Codable, Equatable, Sendable {
  var designInfo: DesignInfo { get }
  var houseLoad: HouseLoad { get }
  var manufacturerAdjustments: AdjustmentMultiplier? { get }
  var systemType: SystemType { get }
}

// MARK: - Results
extension ManualSClient.CoolingInterpolation {
  
  public struct Result: Codable, Equatable, Sendable {
    public let request: ManualSClient.CoolingInterpolation
    public let interpolatedCapacity: CoolingCapacity
    public let excessLatent: Int
    public let finalCapacityAtDesign: CoolingCapacity
    public let altitudeDerating: AdjustmentMultiplier?
    public let capacityAsPercentOfLoad: CapacityAsPercentOfLoad
    
    public init(
      request: ManualSClient.CoolingInterpolation,
      interpolatedCapacity: CoolingCapacity,
      excessLatent: Int,
      finalCapacityAtDesign: CoolingCapacity,
      altitudeDerating: AdjustmentMultiplier?,
      capacityAsPercentOfLoad: CapacityAsPercentOfLoad
    ) {
      self.request = request
      self.interpolatedCapacity = interpolatedCapacity
      self.excessLatent = excessLatent
      self.finalCapacityAtDesign = finalCapacityAtDesign
      self.altitudeDerating = altitudeDerating
      self.capacityAsPercentOfLoad = capacityAsPercentOfLoad
    }
  }
}
