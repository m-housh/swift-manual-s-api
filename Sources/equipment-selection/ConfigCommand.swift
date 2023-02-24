import ArgumentParser
import CliMiddlewareLive
import Dependencies
import Foundation

extension EquipmentSelection {
  struct Config: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(
      abstract: "Configure defaults.",
      subcommands: [SetCommand.self, ShowCommand.self],
      defaultSubcommand: SetCommand.self
    )
  }
}

extension EquipmentSelection.Config {

  enum Key: String, EnumerableFlag {
    case baseUrl
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
      abstract: "Show a default value."
    )

    @Flag
    var key: Key

    func run() async throws {
      @Dependency(\.cliMiddleware) var cliMiddleware
      @Dependency(\.logger) var logger

      switch key {
      case .baseUrl:
        let url = cliMiddleware.baseUrl()
        logger.info("\(url.absoluteString)")
      }
    }
  }

}
