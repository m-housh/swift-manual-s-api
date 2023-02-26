import Foundation
import Models
import Tagged

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Represents configuration / overrides for the command line tool.
///
public struct CliConfig: Codable, Equatable, Sendable {

  /// The API key for generating pdf's.
  ///
  /// This can also be set by an environment variable `ANVIL_API_KEY`.
  ///
  public var anvilApiKey: String

  /// The base url for the ``ApiClient``.
  public var apiBaseUrl: String?

  /// The current directory to read the configuration from.
  ///
  /// This is either set by an environment variable `EQUIPMENT_SELECTION_CONFIG_DIR` or defaults
  /// to `$XDG_CONFIG_HOME/.config/equipment-selection`.
  public var configDirectory: String

  /// The current directory to read template files from.
  ///
  /// This can also be set by an environment variable `EQUIPMENT_SELECTION_TEMPLATES` or
  /// it will default to `$XDG_CONFIG_HOME/.config/equipment-selection/templates`.
  ///
  public var templateDirectoryPath: String?

  /// The template id's to use to generate pdf's with the anvil client.
  public var templateIds: TemplateIds

  /// Override path's / file names for reading templates.
  ///
  public var templatePaths: TemplatePaths

  public init(
    anvilApiKey: String = "deadbeef",
    apiBaseUrl: String? = nil,
    configDirectory: String = defaultConfigPath,
    templateDirectorPath: String? = nil,
    templateIds: TemplateIds = .init(),
    templatePaths: TemplatePaths = .init()
  ) {
    self.anvilApiKey = anvilApiKey
    self.apiBaseUrl = apiBaseUrl
    self.configDirectory = configDirectory
    self.templateDirectoryPath = templateDirectorPath
    self.templateIds = templateIds
    self.templatePaths = templatePaths
  }

  public var configPath: URL {
    let url: URL
    #if !os(Linux)
    if #available(macOS 13.0, *) {
      url = URL(fileURLWithPath: configDirectory, isDirectory: true, relativeTo: .homeDirectory)
    }
    else {
      // Fallback on earlier versions
      url = URL(
        fileURLWithPath: configDirectory,
        relativeTo: FileManager.default.homeDirectoryForCurrentUser
      )
    }
    #else
    url = URL(
      fileURLWithPath: configDirectory,
      relativeTo: FileManager.default.homeDirectoryForCurrentUser
    )
    #endif
    return url.appendingPathComponent(configFileNameKey)
  }
}

private let XDG_CONFIG_HOME_KEY = "XDG_CONFIG_HOME"
private let defaultConfigHomeKey = ".config/equipment-selection"
private let configFileNameKey = "config.json"

public let defaultConfigPath: String = {
  return ProcessInfo.processInfo.environment[XDG_CONFIG_HOME_KEY]
    ?? defaultConfigHomeKey
}()

extension CliConfig {
  public struct TemplatePaths: Codable, Equatable, Sendable {
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

  public struct TemplateIds: Codable, Equatable, Sendable {
    public var noInterpolation: String
    public var oneWayIndoor: String
    public var oneWayOutdoor: String
    public var twoWay: String

    @inlinable
    public init(
      noInterpolation: String = "deadbeef",
      oneWayIndoor: String = "deadbeef",
      oneWayOutdoor: String = "deadbeef",
      twoWay: String = "deadbeef"
    ) {
      self.noInterpolation = noInterpolation
      self.oneWayIndoor = oneWayIndoor
      self.oneWayOutdoor = oneWayOutdoor
      self.twoWay = twoWay
    }
  }
}
