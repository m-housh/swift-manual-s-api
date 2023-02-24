import ApiClientLive
import ArgumentParser
import CliMiddlewareLive
import Dependencies
import Foundation
import LoggingDependency
import Models

extension EquipmentSelection {
  // TODO: Need to not alway generate a pdf.
  struct Interpolate: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
      abstract: "Run an interpolation for the input file."
    )

    @Flag(help: "The interpolation to run.")
    var interpolation: InterpolationName

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

    @Flag(help: "Increase logging output.")
    var verbose: Bool = false

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

    func run() async throws {
      try await withDependencies {
        if verbose {
          $0.logger.logLevel = .debug
        }
        $0.cliMiddleware = .liveValue
      } operation: {
        try await Run(command: self).run()
      }
    }
  }
}

extension EquipmentSelection.Interpolate {

  fileprivate struct Run {
    @Dependency(\.logger) var logger: Logger
    @Dependency(\.cliMiddleware) var cliMiddleware

    let command: EquipmentSelection.Interpolate

    func run() async throws {
      let path = command.interpolation.parseUrl(url: command.inputPath)
      let outputPath = command.outputPath ?? URL(fileURLWithPath: "./")

      let (route, result) = try await interpolate(
        interpolation: command.interpolation,
        inputPath: path
      )

      logger.debug("Recieved Result: \(result)")

      // early out if there are failures.
      if let failures = result.failures, failures.count > 0 {
        logger.info("Failed:")
        logger.info("\(failures)")
        return
      }

      // If caller does not want to write result to json file or generate a pdf
      // log the results to the console.
      if !command.writeJson && !command.generatePdf {
        let jsonString = try String(data: jsonEncoder.encode(result.result), encoding: .utf8) ?? ""
        logger.info("\(jsonString)")
        return
      }

      // Write the result to as json.
      if command.writeJson {
        let jsonPath = outputPath.appendingPathComponent("result.json", conformingTo: .json)
        let data = try jsonEncoder.encode(result.result)
        try await cliMiddleware.writeFile(data, to: jsonPath)
        logger.info("Wrote result to: \(jsonPath.absoluteString)")
      }

      // Generate a pdf and write to disk.
      if command.generatePdf {
        let pdfData = try await cliMiddleware.generatePdf(route, result)
        let pdfPath = outputPath.appendingPathComponent("result.pdf", conformingTo: .pdf)
        try await cliMiddleware.writeFile(pdfData, to: pdfPath)
        logger.info("Wrote result to: \(pdfPath.absoluteString)")
      }
      logger.info("Done")
    }

    private func interpolate(interpolation: InterpolationName, inputPath: URL) async throws -> (
      ServerRoute.Api.Route.Interpolation, InterpolationResponse
    ) {
      let data = try await cliMiddleware.readFile(inputPath)
      let route = try interpolation.route(data: data)
      let response = try await cliMiddleware.interpolate(route)
      return (route, response)
    }

  }
}

// TODO: move
extension InterpolationName {
  fileprivate func route(data: Data) throws -> ServerRoute.Api.Route.Interpolation {
    let decoder = JSONDecoder()
    switch self {
    case .boiler:
      return try .heating(
        .boiler(
          decoder.decode(
            ServerRoute.Api.Route.Interpolation.Heating.Boiler.self,
            from: data
          )
        ))
    case .electric:
      return try .heating(
        .electric(
          decoder.decode(
            ServerRoute.Api.Route.Interpolation.Heating.Electric.self,
            from: data
          )
        ))
    case .furnace:
      return try .heating(
        .furnace(
          decoder.decode(
            ServerRoute.Api.Route.Interpolation.Heating.Furnace.self,
            from: data
          )
        ))
    case .heatPump:
      return try .heating(
        .heatPump(
          decoder.decode(
            ServerRoute.Api.Route.Interpolation.Heating.HeatPump.self,
            from: data
          )
        ))
    case .noInterpolation:
      return try .cooling(
        .noInterpolation(
          decoder.decode(
            ServerRoute.Api.Route.Interpolation.Cooling.NoInterpolation.self,
            from: data
          )
        ))
    case .oneWayIndoor:
      return try .cooling(
        .oneWayIndoor(
          decoder.decode(
            ServerRoute.Api.Route.Interpolation.Cooling.OneWay.self,
            from: data
          )
        ))
    case .oneWayOutdoor:
      return try .cooling(
        .oneWayOutdoor(
          decoder.decode(
            ServerRoute.Api.Route.Interpolation.Cooling.OneWay.self,
            from: data
          )
        ))
    case .twoWay:
      return try .cooling(
        .twoWay(
          decoder.decode(
            ServerRoute.Api.Route.Interpolation.Cooling.TwoWay.self,
            from: data
          )
        ))
    }
  }
}
