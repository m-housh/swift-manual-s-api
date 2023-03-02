import ArgumentParser
import CliMiddleware
import Dependencies
import Foundation
import JsonDependency
import Models

extension EquipmentSelection {
  struct Interpolate: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
      abstract: "Run an interpolation for the input file."
    )

    @Flag(help: "The interpolation to run.")
    var interpolation: Models.Template.PathKey = .project

    @Option(
      name: .shortAndLong,
      help: "The path to the input json file.",
      transform: URL.init(fileURLWithPath:)
    )
    var inputPath: URL?

    @Option(
      name: .shortAndLong,
      help: "The output directory to write files to, if applicable.",
      transform: URL.init(fileURLWithPath:)
    )
    var outputPath: URL?

    @Flag(
      name: [.customLong("pdf"), .customShort("p")],
      help: "Generate a pdf with the result."
    )
    var generatePdf: Bool = false

    @Flag(
      name: [.customLong("json"), .customShort("j")],
      help: "Write the result to a json file."
    )
    var writeJson: Bool = false

    @OptionGroup var globalOptions: GlobalOptions

    func run() async throws {
      try await CliContext(globalOptions: globalOptions) {
        @Dependency(\.cliMiddleware.interpolate) var interpolate
        try await interpolate(self.interpolationContext)
      }
      .run()

    }

    private var interpolationContext: CliMiddleware.InterpolationContext {
      .init(
        key: interpolation,
        generatePdf: generatePdf,
        inputFile: inputPath,
        outputPath: outputPath,
        writeJson: writeJson
      )
    }
  }
}
