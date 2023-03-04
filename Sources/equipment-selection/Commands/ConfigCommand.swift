import ArgumentParser
import CliMiddleware
import Dependencies
import Foundation

extension EquipmentSelection {
  struct Config: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(
      abstract: "Configure settings / defaults.",
      subcommands: [
        GenerateConfigCommand.self,
        ResetCommand.self,
        SetCommand.self,
        ShowCommand.self,
        UnSetCommand.self,
      ],
      defaultSubcommand: SetCommand.self
    )
  }
}

extension EquipmentSelection.Config {

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

  struct ResetCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(
      commandName: "reset",
      abstract: "Reset values that may have been set in user-defaults"
    )

    @OptionGroup var globalOptions: GlobalOptions

    func run() async throws {
      try await CliContext(globalOptions: globalOptions) {
        @Dependency(\.cliMiddleware.config) var config
        try await config(.reset)
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
    var key: CliMiddleware.ConfigContext.Key

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
    var key: CliMiddleware.ConfigContext.Key

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
