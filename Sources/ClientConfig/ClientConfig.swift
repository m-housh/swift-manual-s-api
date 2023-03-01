import Dependencies
import FileClient
import Foundation
import Models
import Tagged

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Represents configuration / overrides for the command line tool.
///
public struct ClientConfig: Codable, Equatable, Sendable {
  
  /// The API key for generating pdf's.
  ///
  /// This can also be set by an environment variable `ANVIL_API_KEY`.
  ///
  public var anvilApiKey: String?

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

  public init() {
    self.anvilApiKey = nil
    self.apiBaseUrl = nil
    self.configDirectory = defaultConfigDirectory
    self.templateDirectoryPath = nil
    self.templateIds = .init()
    self.templatePaths = .init()
  }

  public init(
    environment: Environment,
    templateIds: TemplateIds = .init(),
    templatePaths: Template.Path
  ) {
    self.init(
      anvilApiKey: environment.anvilApiKey,
      apiBaseUrl: environment.apiBaseUrl,
      configDirectory: environment.configDirectory,
      templateDirectoryPath: environment.templateDirectoryPath,
      templateIds: templateIds,
      templatePaths: templatePaths
    )
  }

  internal init(
    anvilApiKey: String?,
    apiBaseUrl: String?,
    configDirectory: String?,
    templateDirectoryPath: String?,
    templateIds: TemplateIds = .init(),
    templatePaths: Template.Path = .init()
  ) {
    self.anvilApiKey = anvilApiKey
    self.apiBaseUrl = apiBaseUrl
    self.configDirectory = configDirectory ?? defaultConfigDirectory
    self.templateDirectoryPath = templateDirectoryPath
    self.templateIds = templateIds
    self.templatePaths = templatePaths
  }

  public var configPath: URL {
    URL(fileURLWithPath: configDirectory)
      .appendingPathComponent(ClientConfig.CONFIG_FILENAME_KEY)
  }
  
  public static let CONFIG_DIRECTORY_KEY = "equipment-selection"
  fileprivate static let CONFIG_FILENAME_KEY = "config.json"
}

extension ClientConfig {
  /// Represents the values that can be read from the process environment.
  ///
  public struct Environment: Codable, Equatable, Sendable {
    public var anvilApiKey: String?
    public var apiBaseUrl: String?
    public var configDirectory: String?
    public var templateDirectoryPath: String?

    public init(
      anvilApiKey: String?,
      apiBaseUrl: String?,
      configDirectory: String?,
      templateDirectoryPath: String?
    ) {
      self.anvilApiKey = anvilApiKey
      self.apiBaseUrl = apiBaseUrl
      self.configDirectory = configDirectory
      self.templateDirectoryPath = templateDirectoryPath
    }

    enum CodingKeys: String, CodingKey {
      case anvilApiKey = "ANVIL_API_KEY"
      case apiBaseUrl = "API_BASE_URL"
      case configDirectory = "EQUIPMENT_SELECTION_CONFIG_DIR"
      case templateDirectoryPath = "EQUIPMENT_SELECTION_TEMPLATES"
    }
  }
}

//public let XDG_CONFIG_HOME_KEY = "XDG_CONFIG_HOME"
//private let defaultConfigHomeKey = ".config/equipment-selection"
//private let configFileNameKey = "config.json"

public let defaultConfigDirectory: String = {
  @Dependency(\.fileClient.configDirectory) var configDirectory
  return configDirectory()
    .appendingPathComponent(ClientConfig.CONFIG_DIRECTORY_KEY)
    .absoluteString
 }()

extension ClientConfig {

  // TODO: Move to AnvilClient.
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
