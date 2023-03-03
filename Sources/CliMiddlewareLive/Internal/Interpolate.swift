import ApiClient
import CliMiddleware
import Dependencies
import FileClient
import Foundation
import JsonDependency
import LoggingDependency
import Models
import SettingsClient

extension CliMiddleware.InterpolationContext {
  @Sendable
  static func run(context: Self) async throws {
    try await Run(context: context).run()
  }
}

extension CliMiddleware.InterpolationContext {
  public struct Run {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.settingsClient) var configClient
    @Dependency(\.fileClient) var fileClient
    @Dependency(\.logger) var logger: Logger
    @Dependency(\.json.jsonEncoder) var jsonEncoder
    @Dependency(\.json.jsonDecoder) var jsonDecoder

    let context: CliMiddleware.InterpolationContext

    public init(context: CliMiddleware.InterpolationContext) {
      self.context = context
    }

    func run() async throws {

      let config = await configClient.settings()
      let path =
        context.inputFile
        ?? URL(fileURLWithPath: config.templatePaths.fileName(for: context.key))
      let outputPath = context.outputPath ?? URL(fileURLWithPath: "./")

      // TODO: Fix for projects.
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
      if !context.writeJson && !context.generatePdf {
        let jsonString =
          try String(data: jsonEncoder.encode(response.result), encoding: .utf8)
          ?? "Failed to encode as string."
        logger.info("\(jsonString)")
        return
      }

      // Write the result as json.
      if context.writeJson {
        let jsonPath = outputPath.appendingPathComponent("result.json")
        let data = try jsonEncoder.encode(response.result)
        try await fileClient.write(data: data, to: jsonPath)
        logger.info("Wrote result to: \(jsonPath.absoluteString)")
      }

      // Generate a pdf and write to disk.
      if context.generatePdf {
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

    // TODO: Fix for projects
    public func interpolate(inputPath: URL)
      async throws -> (
        ServerRoute.Api.Route.Interpolation, InterpolationResponse
      )
    {
      let interpolation: ServerRoute.Api.Route.Interpolation
      do {
        let data = try await fileClient.read(inputPath)
        if context.key != .project {
          interpolation = try jsonDecoder.decode(
            ServerRoute.Api.Route.Interpolation.self,
            from: data
          )
        } else {
          // TODO: Need to also return the project here.
          #warning("Fix to use project")
          logger.debug("Decoding as project.")
          let project = try jsonDecoder.decode(Project.self, from: data)
          interpolation = .single(project.interpolation)
        }
      } catch {
        logger.info("Invalid json.")
        throw error
      }
      logger.debug("Loaded interpolation file at: \(inputPath.absoluteString)")
      logger.debug("Sending api request.")
      let response = try await apiClient.interpolate(interpolation)
      return (interpolation, response)

    }

    // TODO: Fix with anvil client.
    private func generatePdfData(
      interpolation: ServerRoute.Api.Route.Interpolation,
      response: InterpolationResponse
    ) async throws -> Data {
      fatalError()
    }

  }
}
