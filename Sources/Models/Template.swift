public enum Template {
  public struct Path: Codable, Equatable, Sendable {
    public var baseInterpolation: String
    public var boiler: String
    public var electric: String
    public var furnace: String
    public var heatPump: String
    public var keyed: String
    public var noInterpolation: String
    public var oneWayIndoor: String
    public var oneWayOutdoor: String
    public var twoWay: String

    @inlinable
    public init(
      baseInterpolation: String = "baseInterpolation.json",
      boiler: String = "boiler.json",
      electric: String = "electric.json",
      furnace: String = "furnace.json",
      heatPump: String = "heatPump.json",
      keyed: String = "keyed.json",
      noInterpolation: String = "noInterpolation.json",
      oneWayIndoor: String = "oneWayIndoor.json",
      oneWayOutdoor: String = "oneWayOutdoor.json",
      twoWay: String = "twoWay.json"
    ) {
      self.baseInterpolation = baseInterpolation
      self.boiler = boiler
      self.electric = electric
      self.furnace = furnace
      self.heatPump = heatPump
      self.keyed = keyed
      self.noInterpolation = noInterpolation
      self.oneWayIndoor = oneWayIndoor
      self.oneWayOutdoor = oneWayOutdoor
      self.twoWay = twoWay
    }
  }

  public struct BaseInterpolation: Codable, Equatable, Sendable {
    public var designInfo: DesignInfo
    public var houseLoad: HouseLoad
    public var systemType: SystemType?

    @inlinable
    public init(
      designInfo: DesignInfo,
      houseLoad: HouseLoad,
      systemType: SystemType? = nil
    ) {
      self.designInfo = designInfo
      self.houseLoad = houseLoad
      self.systemType = systemType
    }
  }

  public enum PathKey: String, CaseIterable {
    case baseInterpolation
    case boiler
    case electric
    case furnace
    case heatPump
    case keyed
    case noInterpolation
    case oneWayIndoor
    case oneWayOutdoor
    case twoWay
  }
}

extension Template.PathKey {
  public var templateKeyPath: KeyPath<Template.Path, String> {
    switch self {
    case .baseInterpolation:
      return \Template.Path.baseInterpolation
    case .boiler:
      return \Template.Path.boiler
    case .electric:
      return \Template.Path.electric
    case .furnace:
      return \Template.Path.furnace
    case .heatPump:
      return \Template.Path.heatPump
    case .keyed:
      return \Template.Path.keyed
    case .noInterpolation:
      return \Template.Path.noInterpolation
    case .oneWayIndoor:
      return \Template.Path.oneWayIndoor
    case .oneWayOutdoor:
      return \Template.Path.oneWayOutdoor
    case .twoWay:
      return \Template.Path.twoWay
    }
  }
}

extension Template.Path {

  public func fileName(for pathKey: Template.PathKey) -> String {
    self[keyPath: pathKey.templateKeyPath]
  }
}
