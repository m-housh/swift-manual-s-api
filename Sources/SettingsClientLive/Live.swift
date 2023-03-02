@_exported import SettingsClient
import ConcurrencyHelpers
import Dependencies
import FileClient
import Foundation
import Models
import UserDefaultsClient

extension SettingsClient: DependencyKey {

  public static func live(environment: [String: String] = [:]) -> Self {
    actor Session {

      @Dependency(\.fileClient) private var fileClient
      @Dependency(\.userDefaults) private var userDefaults

      nonisolated let settings: Isolated<Settings>

      init(environment: [String: String]) {
        self.settings = .init(
          wrappedValue: bootstrap(environment: environment)
        )
      }

      func generateConfig(at path: URL?) async throws {
        try await self.writeConfig(at: path)
      }

      private func writeConfig(at path: URL? = nil) async throws {

        let configDirectory =
          path
          ?? settings.value.configFileUrl.deletingLastPathComponent()

        try await fileClient.createDirectory(at: configDirectory)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        let data = try encoder.encode(settings.value.localConfig)
        try await fileClient.write(data: data, to: settings.value.configFileUrl)
      }

      func save(config: Settings) async throws {
        self.settings.value = config
        try await self.writeConfig()
      }

      func update(string: String?, forKey defaultsKey: UserDefaultsClient.Key) {
        guard let string else {
          unset(key: defaultsKey)
          return
        }
        setString(string: string, forKey: defaultsKey)
      }

      private func setString(string: String, forKey defaultsKey: UserDefaultsClient.Key) {
        settings.value.setString(string: string, forKey: defaultsKey, with: userDefaults)
      }

      func unset(key defaultsKey: UserDefaultsClient.Key) {
        settings.value.unsetValue(forKey: defaultsKey, with: userDefaults)
      }
    }

    let session = Session(environment: environment)

    return .init(
      settings: { session.settings.value },
      generateConfig: session.generateConfig(at:),
      save: session.save(config:),
      setApiBaseUrl: { await session.update(string: $0, forKey: .apiBaseUrl) },
      setAnvilApiKey: { await session.update(string: $0, forKey: .anvilApiKey) },
      setConfigDirectory: { await session.update(string: $0, forKey: .configDirectory) },
      setTemplateDirectoryPath: { await session.update(string: $0, forKey: .templateDirectory) }
    )
  }

  public static var liveValue: SettingsClient {
    live(environment: ProcessInfo.processInfo.environment)
  }
}

/// Loads the configuration in order.
///
/// - `defaults`
/// - `user-defaults` // implement
/// - `file`
/// - `environment`
///
/// Merging the results together.
fileprivate func bootstrap(environment: [String: String]) -> Settings {
  @Dependency(\.userDefaults) var userDefaults

  var config = Settings()
  let decoder = JSONDecoder()
  let encoder = JSONEncoder()

  userDefaults.merge(with: &config)

  if let localConfig = (try? Data(contentsOf: config.configFileUrl))
    .flatMap({ try? decoder.decode(LocalConfig.self, from: $0) })
  {
    localConfig.merge(with: &config)
  }

  let configEnvironment = (try? encoder.encode(environment))
    .flatMap { try? decoder.decode(Settings.Environment.self, from: $0) }

  if let configEnvironment {
    configEnvironment.merge(with: &config)
  }

  return config
}

extension Settings.Environment {

  fileprivate func merge(with config: inout Settings) {
    if let anvilApiKey { config.anvilApiKey = anvilApiKey }
    if let apiBaseUrl { config.apiBaseUrl = apiBaseUrl }
    if let configDirectory { config.configDirectory = configDirectory }
    if let templateDirectoryPath { config.templateDirectoryPath = templateDirectoryPath }
  }
}

extension UserDefaultsClient {

  fileprivate func merge(with config: inout Settings) {
    if let anvilApiKey = string(forKey: .anvilApiKey) { config.anvilApiKey = anvilApiKey }
    if let apiBaseUrl = string(forKey: .apiBaseUrl) { config.apiBaseUrl = apiBaseUrl }
    if let configDirectory = string(forKey: .configDirectory), configDirectory != "unset" {
      config.configDirectory = configDirectory
    }
    if let templateDirectoryPath = string(forKey: .templateDirectory) {
      config.templateDirectoryPath = templateDirectoryPath
    }
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
  var templateIds: Settings.TemplateIds?
  var templatePaths: Template.Path?

  init(cliConfig: Settings) {
    self.anvilApiKey = cliConfig.anvilApiKey
    self.apiBaseUrl = cliConfig.apiBaseUrl
    self.templateDirectoryPath = cliConfig.templateDirectoryPath
    self.templateIds = cliConfig.templateIds
    self.templatePaths = cliConfig.templatePaths
  }

  func merge(with config: inout Settings) {
    if let anvilApiKey { config.anvilApiKey = anvilApiKey }
    if let apiBaseUrl { config.apiBaseUrl = apiBaseUrl }
    if let templateDirectoryPath { config.templateDirectoryPath = templateDirectoryPath }
    if let templateIds { config.templateIds = templateIds }
    if let templatePaths { config.templatePaths = templatePaths }
  }
}

extension Settings {
  // Convert a cli-config to a local-config.
  fileprivate var localConfig: LocalConfig { .init(cliConfig: self) }
}

extension Settings {
  fileprivate mutating func setString(
    string: String,
    forKey defaultsKey: UserDefaultsClient.Key,
    with userDefaults: UserDefaultsClient
  ) {
    userDefaults.setString(string, forKey: defaultsKey)
    switch defaultsKey {
    case .anvilApiKey:
      self.anvilApiKey = string
    case .apiBaseUrl:
      self.apiBaseUrl = string
    case .anvilBaseUrl:
      return
    case .configDirectory:
      self.configDirectory = string
    case .templateDirectory:
      self.templateDirectoryPath = string
    }
  }

  fileprivate mutating func unsetValue(
    forKey defaultsKey: UserDefaultsClient.Key,
    with userDefaults: UserDefaultsClient
  ) {
    userDefaults.removeValue(forKey: defaultsKey)
    switch defaultsKey {
    case .anvilApiKey:
      self.anvilApiKey = nil
    case .apiBaseUrl:
      self.apiBaseUrl = nil
    case .anvilBaseUrl:
      return
    case .configDirectory:
      // set the config directory back to a default value.
      self.configDirectory = bootstrap(
        environment: ProcessInfo.processInfo.environment
      ).configDirectory
    case .templateDirectory:
      self.templateDirectoryPath = nil
    }
  }
}
