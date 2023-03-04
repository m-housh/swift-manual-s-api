import CliMiddleware
import Dependencies
import Foundation
import JsonDependency
import LoggingDependency
import SettingsClient
import UserDefaultsClient

extension CliMiddleware.ConfigContext {

  @Sendable
  static func run(context: Self) async throws {
    switch context {
    case .generate:
      try await Run.generate()
    case .reset:
      try await Run.reset()
    case let .set(string, for: key):
      try await Run.set(string: string, forKey: key)
    case .show:
      try await Run.show()
    case let .unset(key):
      try await Run.unset(key: key)
    }
  }
}

extension CliMiddleware.ConfigContext {
  fileprivate enum Run {

    static func reset() async throws {
      @Dependency(\.logger) var logger: Logger
      @Dependency(\.userDefaults) var userDefaults: UserDefaultsClient

      userDefaults.reset()
      logger.info("Reset user defaults.")
    }

    static func generate() async throws {
      @Dependency(\.settingsClient) var configClient
      @Dependency(\.logger) var logger

      let config = await configClient.settings()
      try await configClient.generateConfig()

      logger.info(
        "Wrote config to path: \(config.configFileUrl.absoluteString)"
      )
    }

    static func set(string: String, forKey key: Key) async throws {
      @Dependency(\.settingsClient) var configClient
      @Dependency(\.logger) var logger

      switch key {
      case .anvilApiKey:
        logger.debug("Setting anvil api key.")
        await configClient.setAnvilApiKey(string)
      case .apiBaseUrl:
        logger.debug("Setting api base url.")
        await configClient.setApiBaseUrl(string)
      case .configDirectory:
        logger.debug("Setting config directory.")
        await configClient.setConfigDirectory(string)
      case .templatesDirectory:
        logger.debug("Setting templates directory.")
        await configClient.setTemplateDirectoryPath(string)
      }
      logger.info("Done")
    }

    static func show() async throws {
      @Dependency(\.settingsClient) var cliConfigClient
      @Dependency(\.logger) var logger
      @Dependency(\.json.jsonEncoder) var jsonEncoder

      let config = await cliConfigClient.settings()
      let string = try String(data: jsonEncoder.encode(config), encoding: .utf8)!
      logger.info("\(string)")
    }

    static func unset(key: Key) async throws {
      @Dependency(\.settingsClient) var configClient
      @Dependency(\.logger) var logger
      switch key {
      case .anvilApiKey:
        logger.debug("Unsetting anvil api key.")
        await configClient.setAnvilApiKey(nil)
      case .apiBaseUrl:
        logger.debug("Unsetting api base url.")
        await configClient.setApiBaseUrl(nil)
      case .configDirectory:
        logger.debug("Unsetting config directory.")
        await configClient.setConfigDirectory(nil)
      case .templatesDirectory:
        logger.debug("Unsetting templates directory.")
        await configClient.setTemplateDirectoryPath(nil)
      }
      logger.info("Done")
    }

  }
}
