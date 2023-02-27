import ArgumentParser
import CliConfigLive
import CliMiddlewareLive
import Dependencies
import Foundation
import TemplateClientLive

extension EquipmentSelection {
  struct Config: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(
      abstract: "Configure defaults.",
      subcommands: [
        GenerateConfigCommand.self,
        GenerateTemplatesCommand.self,
        RemoveTemplatesCommand.self,
        SetCommand.self,
        ShowCommand.self,
        UnSetCommand.self
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

    func run() async throws {
      try await withDependencies {
        $0.cliConfigClient = .liveValue
      } operation: {
        @Dependency(\.cliConfigClient) var cliConfigClient
        @Dependency(\.logger) var logger

        let config = try await cliConfigClient.config()

        try await cliConfigClient.generateConfig()
        logger.info("Wrote config to path: \(config.configPath.absoluteString)")
      }
    }
  }

  // TODO: Move template commands.
  struct GenerateTemplatesCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(
      commandName: "generate-templates",
      abstract: "Generate local template files."
    )

    func run() async throws {
      try await withDependencies {
        $0.templateClient = .live(jsonEncoder: jsonEncoder)
      } operation: {
        @Dependency(\.templateClient) var templateClient
        @Dependency(\.logger) var logger

        let templatesPath = templateClient.templateDirectory()
        try await templateClient.generateTemplates()
        logger.info("Wrote templates to path: \(templatesPath.absoluteString)")
      }
    }
  }

  struct RemoveTemplatesCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(
      commandName: "remove-templates",
      abstract: "Remove local template files."
    )

    func run() async throws {
      try await withDependencies {
        $0.templateClient = .live(jsonEncoder: jsonEncoder)
      } operation: {
        @Dependency(\.templateClient) var templateClient
        @Dependency(\.logger) var logger

        let templatesPath = templateClient.templateDirectory()
        try await templateClient.removeTemplateDirectory()
        logger.info("Deleted templates at path: \(templatesPath.absoluteString)")
      }
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

    func run() async throws {
      @Dependency(\.cliConfigClient) var configClient
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
  }

  struct ShowCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(
      commandName: "show",
      abstract: "Show the current configuration values."
    )

    func run() async throws {
      @Dependency(\.cliConfigClient) var cliConfigClient
      @Dependency(\.logger) var logger

      let config = try await cliConfigClient.config()
      let string = try String(data: jsonEncoder.encode(config), encoding: .utf8)!
      logger.info("\(string)")

    }
  }
  
  struct UnSetCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(
      commandName: "set",
      abstract: "Unset / remove a configuration value."
    )

    @Flag
    var key: UnSetKey
    
    func run() async throws {
      @Dependency(\.cliConfigClient) var configClient
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
  }
}
