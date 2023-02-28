import ApiClientLive
import ArgumentParser
import ClientConfigLive
import Dependencies
import Foundation
import Logging
import LoggingFormatAndPipe
import Models
import TemplateClientLive

@main
struct EquipmentSelection: AsyncParsableCommand {

  static var configuration = CommandConfiguration(
    abstract: "A utility for performing equipment selection requests.",
    subcommands: [Template.self, Interpolate.self, Config.self]
  )
}

struct GlobalOptions: ParsableArguments {
  @Flag(
    name: .shortAndLong,
    help: "Increase logging output."
  )
  var verbose = false
}

// Sets up the default live dependencies for commands.
struct CliContext {
  let globalOptions: GlobalOptions
  let _run: () async throws -> Void

  init(
    globalOptions: GlobalOptions,
    run: @escaping () async throws -> Void
  ) {
    self.globalOptions = globalOptions
    self._run = run
  }

  func run() async throws {
    try await withDependencies {
      $0.logger = .cliLogger
      if globalOptions.verbose {
        $0.logger.logLevel = .debug
      }
      $0.configClient = .liveValue
      $0.templateClient = .live(jsonEncoder: .cliEncoder)
      $0.jsonCoders = .liveValue
      $0.apiClient = .liveValue
    } operation: {
      try await self._run()
    }
  }
}

// TODO: Setup a CliContext that sets up dependencies for commands.
extension JSONEncoder: DependencyKey {
  static func cliEncoder(
    _ formatting: JSONEncoder.OutputFormatting
  ) -> JSONEncoder {
    let encoder = JSONEncoder()
    encoder.outputFormatting = formatting
    return encoder
  }

  static var cliEncoder: JSONEncoder {
    self.cliEncoder([.prettyPrinted, .sortedKeys])
  }

  public static let liveValue: JSONEncoder = .cliEncoder
}

extension JSONDecoder: DependencyKey {
  public static let liveValue: JSONDecoder = .init()
}

struct JSONCoders: DependencyKey {
  var jsonDecoder: JSONDecoder = .liveValue
  var jsonEncoder: JSONEncoder = .liveValue

  static var liveValue: JSONCoders = .init()
}
extension DependencyValues {
  var jsonCoders: JSONCoders {
    get { self[JSONCoders.self] }
    set { self[JSONCoders.self] = newValue }
  }
}

extension Logger {

  static var cliLogger: Self {
    Logger(label: "equipment-selection") { _ in
      return LoggingFormatAndPipe.Handler(
        formatter: BasicFormatter([.message]),
        pipe: LoggerTextOutputStreamPipe.standardOutput
      )
    }
  }

  static var cliLoggerWithLevel: Self {
    Logger(label: "equipment-selection") { _ in
      return LoggingFormatAndPipe.Handler(
        formatter: BasicFormatter([.level, .message]),
        pipe: LoggerTextOutputStreamPipe.standardOutput
      )
    }
  }
}

extension Template.PathKey: EnumerableFlag {}
