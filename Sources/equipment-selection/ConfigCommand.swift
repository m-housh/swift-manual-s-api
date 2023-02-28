import ArgumentParser
import ClientConfigLive
import Dependencies
import Foundation
import TemplateClientLive

extension EquipmentSelection {
  struct Config: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(
      abstract: "Configure defaults.",
      subcommands: [
        GenerateConfigCommand.self,
        SetCommand.self,
        ShowCommand.self,
        UnSetCommand.self,
      ],
      defaultSubcommand: SetCommand.self
    )
  }
}

extension EquipmentSelection.Config {

  enum SetKey: String, EnumerableFlag {
    case anvilApiKey
    case apiBaseUrl
    case configDirectory
    case templatesDirectory
  }

  enum UnSetKey: String, EnumerableFlag {
    case anvilApiKey
    case apiBaseUrl
    case templatesDirectory
  }

  struct GenerateConfigCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(
      commandName: "generate-config",
      abstract: "Generate a local configuration file."
    )

    @OptionGroup var globalOptions: GlobalOptions

    func run() async throws {
      try await CliContext(globalOptions: globalOptions) {
        @Dependency(\.configClient) var cliConfigClient
        @Dependency(\.logger) var logger

        let config = try await cliConfigClient.config()

        try await cliConfigClient.generateConfig()
        logger.info("Wrote config to path: \(config.configPath.absoluteString)")
      }
      .run()
    }
  }

  struct SetCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(
      commandName: "set",
      abstract: "Set a configuration value."
    )

    @Flag
    var key: SetKey

    @Argument
    var value: String

    @OptionGroup var globalOptions: GlobalOptions

    func run() async throws {
      try await CliContext(globalOptions: globalOptions) {
        @Dependency(\.configClient) var configClient
        @Dependency(\.logger) var logger

        switch key {
        case .anvilApiKey:
          logger.debug("Setting anvil api key.")
          await configClient.setAnvilApiKey(value)
        case .apiBaseUrl:
          logger.debug("Setting api base url.")
          await configClient.setApiBaseUrl(value)
        case .configDirectory:
          logger.debug("Setting config directory.")
          await configClient.setConfigDirectory(value)
        case .templatesDirectory:
          logger.debug("Setting templates directory.")
          await configClient.setTemplateDirectoryPath(value)
        }
        logger.info("Done")
      }
      .run()
    }
  }

  struct ShowCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(
      commandName: "show",
      abstract: "Show the current configuration values."
    )

    @OptionGroup var globalOptions: GlobalOptions

    func run() async throws {
      try await CliContext(globalOptions: globalOptions) {
        @Dependency(\.configClient) var cliConfigClient
        @Dependency(\.logger) var logger
        @Dependency(\.jsonCoders.jsonEncoder) var jsonEncoder

        let config = try await cliConfigClient.config()
        let string = try String(data: jsonEncoder.encode(config), encoding: .utf8)!
        logger.info("\(string)")
      }
      .run()
    }
  }

  struct UnSetCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(
      commandName: "set",
      abstract: "Unset / remove a configuration value."
    )

    @Flag
    var key: UnSetKey

    @OptionGroup var globalOptions: GlobalOptions

    func run() async throws {
      try await CliContext(globalOptions: globalOptions) {
        @Dependency(\.configClient) var configClient
        @Dependency(\.logger) var logger

        switch key {
        case .anvilApiKey:
          logger.debug("Unsetting anvil api key.")
          await configClient.setAnvilApiKey(nil)
        case .apiBaseUrl:
          logger.debug("Unsetting api base url.")
          await configClient.setApiBaseUrl(nil)
        case .templatesDirectory:
          logger.debug("Unsetting templates directory.")
          await configClient.setTemplateDirectoryPath(nil)
        }
        logger.info("Done")
      }
      .run()
    }
  }
}
