import ApiClientLive
import ArgumentParser
import ClientConfig
import Dependencies
import Foundation
import LoggingDependency
import Models
import Tagged

extension EquipmentSelection {
  struct Interpolate: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
      abstract: "Run an interpolation for the input file."
    )

    @Flag(help: "The interpolation to run.")
    var interpolation: Models.Template.PathKey = .keyed

    @Option(
      name: .shortAndLong,
      help: "The path to the input json file.",
      transform: URL.init(fileURLWithPath:)
    )
    var inputPath: URL?

    @Option(
      name: .shortAndLong,
      help: "The output directory to write files to.",
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
      try await CliContext(
        globalOptions: globalOptions,
        run: Run(command: self).run
      )
      .run()
    }
  }
}

extension EquipmentSelection.Interpolate {

  fileprivate struct Run {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.configClient) var configClient
    @Dependency(\.fileClient) var fileClient
    @Dependency(\.logger) var logger: Logger
    @Dependency(\.jsonCoders.jsonEncoder) var jsonEncoder
    @Dependency(\.jsonCoders.jsonDecoder) var jsonDecoder

    let command: EquipmentSelection.Interpolate

    func run() async throws {
      let config = try await configClient.config()
      let path = command.inputPath
      ?? URL(fileURLWithPath: config.templatePaths.fileName(for: command.interpolation))
      let outputPath = command.outputPath ?? URL(fileURLWithPath: "./")

      let (interpolation, response) = try await interpolate(
        inputPath: path
      )

      logger.debug("Recieved Result: \(response)")

      // early out if there are failures.
      if let failures = response.failures, failures.count > 0 {
        logger.info("Failed:")
        logger.info("\(failures)")
        return
      }

      // If caller does not want to write result to json file or generate a pdf
      // log the results to the console.
      if !command.writeJson && !command.generatePdf {
        let jsonString = try String(data: jsonEncoder.encode(response.result), encoding: .utf8) ?? ""
        logger.info("\(jsonString)")
        return
      }

      // Write the result to as json.
      if command.writeJson {
        let jsonPath = outputPath.appendingPathComponent("result.json")
        let data = try jsonEncoder.encode(response.result)
        try await fileClient.write(data: data, to: jsonPath)
        logger.info("Wrote result to: \(jsonPath.absoluteString)")
      }

      // Generate a pdf and write to disk.
      if command.generatePdf {
        let pdfData = try await generatePdfData(
          interpolation: interpolation,
          response: response
        )
        let pdfPath = outputPath.appendingPathComponent("result.pdf")
        try await fileClient.write(data: pdfData, to: pdfPath)
        logger.info("Wrote result to: \(pdfPath.absoluteString)")
      }
      logger.info("Done")
    }

    private func interpolate(inputPath: URL)
      async throws -> (
        ServerRoute.Api.Route.Interpolation, InterpolationResponse
      )
    {
      let data = try await fileClient.read(inputPath)
      let interpolation = try jsonDecoder.decode(
        ServerRoute.Api.Route.Interpolation.self,
        from: data
      )
      logger.debug("Read interpolation file at: \(inputPath.absoluteString)")
      let response = try await apiClient.interpolate(interpolation)
      return (interpolation, response)
    }

  }
}

// TODO: Fix with anvil client.
fileprivate func generatePdfData(
  interpolation: ServerRoute.Api.Route.Interpolation,
  response: InterpolationResponse
) async throws -> Data {
  fatalError()
}

