import ArgumentParser
import Foundation
import Models

@main
struct EquipmentSelection: AsyncParsableCommand {

  static var configuration = CommandConfiguration(
    abstract: "A utility for performing equipment selection requests.",
    subcommands: [Template.self, Interpolate.self]
  )

  func run() async throws {
    // do something
    print("FIX ME.")
  }
}

let jsonEncoder: JSONEncoder = {
  let encoder = JSONEncoder()
  encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
  return encoder
}()
