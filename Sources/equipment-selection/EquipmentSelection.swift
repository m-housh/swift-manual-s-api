import ArgumentParser
import Foundation
import Logging
import LoggingFormatAndPipe
import Models

@main
struct EquipmentSelection: AsyncParsableCommand {

  static var configuration = CommandConfiguration(
    abstract: "A utility for performing equipment selection requests.",
    subcommands: [Template.self, Interpolate.self, Config.self]
  )
}

// TODO: Setup a CliContext that sets up dependencies for commands.
let jsonEncoder: JSONEncoder = {
  let encoder = JSONEncoder()
  encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
  return encoder
}()

let loggerWithLevel = Logger(label: "equipment-selection") { _ in
  return LoggingFormatAndPipe.Handler(
    formatter: BasicFormatter([.level, .message]),
    pipe: LoggerTextOutputStreamPipe.standardError
  )
}

let logger = Logger(label: "equipment-selection") { _ in
  return LoggingFormatAndPipe.Handler(
    formatter: BasicFormatter([.message]),
    pipe: LoggerTextOutputStreamPipe.standardError
  )
}
