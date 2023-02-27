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
  /// to `$(XDG_CONFIG_HOME)/.config/equipment-selection`.
  public var configDirectory: String

  /// The current directory to read template files from.
  ///
  /// This can also be set by an environment variable `EQUIPMENT_SELECTION_TEMPLATES` or
  /// it will default to `$(XDG_CONFIG_HOME)/.config/equipment-selection/templates`.
  ///
  public var templateDirectoryPath: String?

  /// The template id's to use to generate pdf's with the anvil client.
  public var templateIds: TemplateIds

  /// Override path's / file names for reading templates.
  ///
  public var templatePaths: Template.Path

  public init(
    anvilApiKey: String = "deadbeef",
    apiBaseUrl: String? = nil,
    configDirectory: String = defaultConfigPath,
    templateDirectorPath: String? = nil,
    templateIds: TemplateIds = .init(),
    templatePaths: Template.Path = .init()
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
      } else {
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

public let XDG_CONFIG_HOME_KEY = "XDG_CONFIG_HOME"
private let defaultConfigHomeKey = ".config/equipment-selection"
private let configFileNameKey = "config.json"

public let defaultConfigPath: String = {
  return ProcessInfo.processInfo.environment[XDG_CONFIG_HOME_KEY]
    ?? defaultConfigHomeKey
}()

extension CliConfig {

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
