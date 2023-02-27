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
        ShowCommand.self
      ],
      defaultSubcommand: SetCommand.self
    )
  }
}

extension EquipmentSelection.Config {

  enum Key: String, EnumerableFlag {
    case baseUrl
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
      abstract: "Set a default value."
    )

    @Flag
    var key: Key

    @Argument
    var value: String

    func run() async throws {
      @Dependency(\.cliMiddleware) var cliMiddleware
      @Dependency(\.logger) var logger

      switch key {
      case .baseUrl:
        await cliMiddleware.setBaseUrl(URL(string: value)!)
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
}
