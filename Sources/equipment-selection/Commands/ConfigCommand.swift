import ArgumentParser
import CliMiddleware
import Dependencies
import Foundation

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

  //  enum SetKey: String, EnumerableFlag {
  //    case anvilApiKey
  //    case apiBaseUrl
  //    case configDirectory
  //    case templatesDirectory
  //  }
  //
  //  enum UnSetKey: String, EnumerableFlag {
  //    case anvilApiKey
  //    case apiBaseUrl
  //    case templatesDirectory
  //  }

  struct GenerateConfigCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(
      commandName: "generate",
      abstract: "Generate a local configuration file."
    )

    @OptionGroup var globalOptions: GlobalOptions

    func run() async throws {
      try await CliContext(globalOptions: globalOptions) {
        @Dependency(\.cliMiddleware.config) var config
        try await config(.generate)
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
    var key: CliMiddleware.ConfigContext.SetKey

    @Argument
    var value: String

    @OptionGroup var globalOptions: GlobalOptions

    func run() async throws {
      try await CliContext(globalOptions: globalOptions) {
        @Dependency(\.cliMiddleware.config) var config
        try await config(.set(value, for: key))
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
        @Dependency(\.cliMiddleware.config) var config
        try await config(.show)
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
    var key: CliMiddleware.ConfigContext.UnSetKey

    @OptionGroup var globalOptions: GlobalOptions

    func run() async throws {
      try await CliContext(globalOptions: globalOptions) {
        @Dependency(\.cliMiddleware.config) var config
        try await config(.unset(key))
      }
      .run()
    }
  }
}
