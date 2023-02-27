@_exported import CliConfig
import ConcurrencyHelpers
import Dependencies
import FileClient
import Foundation
import Models

extension CliConfigClient: DependencyKey {

  public static var liveValue: CliConfigClient {

    actor Session {

      @Dependency(\.fileClient) var fileClient

      nonisolated let config: Isolated<CliConfig> = .init(wrappedValue: CliConfigLive.config())

      func generateConfig(at path: URL?) async throws {
        try await self.writeConfig(at: path)
      }

      private func writeConfig(at path: URL? = nil) async throws {

        let configDirectory =
          path
          ?? config.value.configPath.deletingLastPathComponent()

        try await fileClient.createDirectory(at: configDirectory)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        let data = try encoder.encode(config.value.localConfig)
        try await fileClient.write(data: data, to: config.value.configPath)
      }

      func save(config: CliConfig) async throws {
        self.config.value = config
        try await self.writeConfig()
      }
    }

    let session = Session()

    return .init(
      config: {
        session.config.value
      },
      generateConfig: session.generateConfig(at:),
      save: session.save(config:)
    )
  }
}

/// Loads the configuration in order.
///
/// - `defaults`
/// - `file`
/// - `environment`
///
/// Merging the results together.
private func config() -> CliConfig {

  var config = CliConfig()
  let decoder = JSONDecoder()
  let encoder = JSONEncoder()

  if let localConfig = (try? Data(contentsOf: config.configPath))
    .flatMap({ try? decoder.decode(LocalConfig.self, from: $0) })
  {
    localConfig.merge(with: &config)
  }

  let configEnvironment = (try? encoder.encode(ProcessInfo.processInfo.environment))
    .flatMap { try? decoder.decode(ConfigEnvironment.self, from: $0) }

  if let configEnvironment {
    configEnvironment.merge(with: &config)
  }

  return config
}

// Represents the values that can be read from the process environment.
private struct ConfigEnvironment: Decodable {
  var anvilApiKey: String?
  var apiBaseUrl: String?
  var configDirectory: String?
  var templateDirectoryPath: String?

  func merge(with config: inout CliConfig) {
    if let anvilApiKey { config.anvilApiKey = anvilApiKey }
    if let apiBaseUrl { config.apiBaseUrl = apiBaseUrl }
    if let configDirectory { config.configDirectory = configDirectory }
    if let templateDirectoryPath { config.templateDirectoryPath = templateDirectoryPath }
  }

  enum CodingKeys: String, CodingKey {
    case anvilApiKey = "ANVIL_API_KEY"
    case apiBaseUrl = "API_BASE_URL"
    case configDirectory = "EQUIPMENT_SELCTION_CONFIG_DIR"
    case templateDirectoryPath = "EQUIPMENT_SELECTION_TEMPLATES"
  }
}

// Represents the config values that can be read / saved to disk.
// This allows the config value used by the application to have a value
// for where the configuration files live, but it can't be overwritten in a
// file.  It can however be overwritten by the environment variables or user defaults.
private struct LocalConfig: Codable {
  var anvilApiKey: String?
  var apiBaseUrl: String?
  var templateDirectoryPath: String?
  var templateIds: CliConfig.TemplateIds?
  var templatePaths: Template.Path?

  init(cliConfig: CliConfig) {
    self.anvilApiKey = cliConfig.anvilApiKey
    self.apiBaseUrl = cliConfig.apiBaseUrl
    self.templateDirectoryPath = cliConfig.templateDirectoryPath
    self.templateIds = cliConfig.templateIds
    self.templatePaths = cliConfig.templatePaths
  }

  func merge(with config: inout CliConfig) {
    if let anvilApiKey { config.anvilApiKey = anvilApiKey }
    if let apiBaseUrl { config.apiBaseUrl = apiBaseUrl }
    if let templateDirectoryPath { config.templateDirectoryPath = templateDirectoryPath }
    if let templateIds { config.templateIds = templateIds }
    if let templatePaths { config.templatePaths = templatePaths }
  }
}

extension CliConfig {
  // Convert a cli-config to a local-config.
  fileprivate var localConfig: LocalConfig { .init(cliConfig: self) }
}
