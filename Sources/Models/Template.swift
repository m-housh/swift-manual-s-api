/// Represents common template values that are used in client applications.
///
public enum Template {

  /// Represents path's / file names for template overrides.
  public struct Path: Codable, Equatable, Sendable {

    /// The file path in the templates folder to find base interpolation overrides.
    public var baseInterpolation: String

    /// The file path in the templates folder to find boiler interpolation overrides.
    public var boiler: String

    /// The file path in the templates folder to find electric interpolation overrides.
    public var electric: String

    /// The file path in the templates folder to find furnace interpolation overrides.
    public var furnace: String

    /// The file path in the templates folder to find heat-pump interpolation overrides.
    public var heatPump: String

    /// The file path in the templates folder to find no-interpolation interpolation overrides.
    public var noInterpolation: String

    /// The file path in the templates folder to find one-way-indoor interpolation overrides.
    public var oneWayIndoor: String

    /// The file path in the templates folder to find one-way-outdoor interpolation overrides.
    public var oneWayOutdoor: String

    /// The file path in the templates folder to find project overrides.
    public var project: String

    /// The file path in the templates folder to find two-way interpolation overrides.
    public var twoWay: String

    /// Create a new ``Template/Path`` instance.
    ///
    /// - Parameters:
    ///   - baseInterpolation: The path to find base interpolation overrides.
    ///   - boiler: The path to find boiler overrides.
    ///   - electric: The path to find electric overrides.
    ///   - furnace: The path to find furnace overrides.
    ///   - heatPump: The path  to find heat pump overrides.
    ///   - noInterpolation: The path to find the no-interpolation overrides.
    ///   - oneWayIndoor: The path to find the one way indoor overrides.
    ///   - oneWayOutdoor: The path to find the one way outdoor overrides.
    ///   - project: The path to find project overrides.
    ///   - systems: The path to find systems overrides.
    ///   - twoWay: The path to find the two way overrides.
    @inlinable
    public init(
      baseInterpolation: String = "baseInterpolation.json",
      boiler: String = "boiler.json",
      electric: String = "electric.json",
      furnace: String = "furnace.json",
      heatPump: String = "heatPump.json",
      noInterpolation: String = "noInterpolation.json",
      oneWayIndoor: String = "oneWayIndoor.json",
      oneWayOutdoor: String = "oneWayOutdoor.json",
      project: String = "project.json",
      twoWay: String = "twoWay.json"
    ) {
      self.baseInterpolation = baseInterpolation
      self.boiler = boiler
      self.electric = electric
      self.furnace = furnace
      self.heatPump = heatPump
      self.noInterpolation = noInterpolation
      self.oneWayIndoor = oneWayIndoor
      self.oneWayOutdoor = oneWayOutdoor
      self.project = project
      self.twoWay = twoWay
    }
  }

  /// Represents basic interpolation values for templates, not including the interpolation route data.
  ///
  ///
  public struct BaseInterpolation: Codable, Equatable, Sendable {

    /// The default design information to use within templates.
    public var designInfo: DesignInfo

    /// The default house load information to use within templates.
    public var houseLoad: HouseLoad

    /// The default system type information to use within templates that require it.
    public var systemType: SystemType?

    /// Create a new ``Template/BaseInterpolation`` to use in templates.
    ///
    /// - Parameters:
    ///   - designInfo: The default design information.
    ///   - houseLoad: The default house load.
    ///   - systemType: The default system type, if applicable.
    @inlinable
    public init(
      designInfo: DesignInfo = .init(),
      houseLoad: HouseLoad = .init(),
      systemType: SystemType? = nil
    ) {
      self.designInfo = designInfo
      self.houseLoad = houseLoad
      self.systemType = systemType
    }
  }

  /// Represents key's used to access / set template path values in ``Template/Path``.
  ///
  ///
  public enum PathKey: String, CaseIterable, Sendable {
    case baseInterpolation
    case boiler
    case electric
    case furnace
    case heatPump
    case noInterpolation
    case oneWayIndoor
    case oneWayOutdoor
    case project
    case twoWay
  }

  /// Represents key's that can be embedded in an interpolation template.
  ///
  public enum EmbeddableKey: String, CaseIterable, Sendable {
    case boiler
    case electric
    case furnace
    case heatPump
    case noInterpolation
    case oneWayIndoor
    case oneWayOutdoor
    case twoWay
  }
}

extension Template.PathKey {

  /// Return's the key path for ``Template/Path`` for the given key.
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
    case .noInterpolation:
      return \Template.Path.noInterpolation
    case .oneWayIndoor:
      return \Template.Path.oneWayIndoor
    case .oneWayOutdoor:
      return \Template.Path.oneWayOutdoor
    case .project:
      return \Template.Path.project
    case .twoWay:
      return \Template.Path.twoWay
    }
  }

  /// Convert the path key to an ``Template/EmbeddableKey``.
  ///
  public var embeddableKey: Template.EmbeddableKey? {
    .init(rawValue: rawValue)
  }
}

extension Template.EmbeddableKey {

  /// Convert the embeddable key to a ``Template/PathKey``.
  public var pathKey: Template.PathKey {
    .init(rawValue: self.rawValue)!
  }

  /// Represents the key-path to access the template file name from a ``Template/Path`` instance.
  public var templateKeyPath: KeyPath<Template.Path, String> {
    pathKey.templateKeyPath
  }
}

extension Template.Path {

  /// Return the value for the given ``Template/PathKey``.
  public func fileName(for pathKey: Template.PathKey) -> String {
    self[keyPath: pathKey.templateKeyPath]
  }
}
