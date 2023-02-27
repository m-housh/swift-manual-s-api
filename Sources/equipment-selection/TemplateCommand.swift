import ArgumentParser
import CliMiddleware
import Dependencies
import FirstPartyMocks
import Foundation
import Logging
import LoggingDependency
import Models

#if canImport(AppKit)
  import AppKit
#endif

extension EquipmentSelection {
  struct Template: AsyncParsableCommand {

    static var configuration: CommandConfiguration = .init(
      commandName: "template",
      abstract: "Commands for working with the templates system.",
      subcommands: [
        Config.GenerateTemplatesCommand.self,
        Config.RemoveTemplatesCommand.self,
        GenerateCommand.self,
      ],
      defaultSubcommand: GenerateCommand.self
    )
  }
}

extension EquipmentSelection.Template {

  struct GenerateCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(
      commandName: "generate",
      abstract: "Generate a local configuration value or file."
    )

    @Flag(help: "The template to generate.")
    var templateKey: Template.PathKey = .keyed

    @Flag(
      inversion: .prefixedNo,
      help: "Copy the value to the pasteboard (only works on macOS)."
    )
    var copy: Bool = false

    @Flag(
      inversion: .prefixedNo,
      help: "Print the template to standard-output (default)"
    )
    var echo: Bool = true

    @Flag(
      name: [.long, .customShort("i")],
      help: "Embeds the template inside an interpolation context."
    )
    var embedInInterpolation: Bool = false

    @Flag(
      name: [.long, .customShort("r")],
      help: """
        Embeds the template inside of an interpolation route context (not all template keys are
        compatible with this option).
      """
    )
    var embedInRoute: Bool = false

    @Option(
      name: .shortAndLong,
      help: "If supplied then the template will be written to a file in the output path.",
      transform: URL.init(fileURLWithPath:)
    )
    var outputPath: URL?

    @Flag(help: "Print more verbose logs.")
    var verbose: Bool = false

    // Represents the operation string, used for verbose logging.
    private var operationString: String {
      if copy { return "copy" }
      if !copy && !echo { return "write" }
      return "echo"
    }

    func run() async throws {
      try await withDependencies {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        $0.templateClient = .live(jsonEncoder: encoder)
        $0.logger = logger
        if verbose {
          $0.logger.logLevel = .debug
        }
      } operation: {
        @Dependency(\.cliConfigClient) var configClient
        @Dependency(\.fileClient) var fileClient
        @Dependency(\.logger) var logger
        @Dependency(\.templateClient) var templateClient

        let templateData: Data

        if !embedInRoute {
          templateData = try await templateClient.template(
            for: templateKey,
            inInterpolation: embedInInterpolation
          )
        } else {
          
          guard let embeddableKey = Template.EmbeddableKey(rawValue: templateKey.rawValue) else {
            struct NotEmbeddableError: Error { }
            throw NotEmbeddableError()
          }
          let route = try await templateClient.routeTemplate(for: embeddableKey)
          switch route {
          case .cooling(route: let cooling):
            templateData = try jsonEncoder.encode(cooling)
          case .heating(route: let heating):
            templateData = try jsonEncoder.encode(heating)
          case .keyed(_):
            templateData = try jsonEncoder.encode(route)
          }
        }

        let config = try await configClient.config()
        if let outputPath {
          let fileName = config.templatePaths.fileName(for: templateKey)
          let outputUrl = outputPath.appendingPathComponent(fileName)
          try await fileClient.write(data: templateData, to: outputUrl)
          logger.info("Wrote template to: \(outputUrl.absoluteString)")
          return
        } else {

          guard let templateString = String(data: templateData, encoding: .utf8) else {
            struct TemplateError: Error {}
            logger.info("Failed to parse template string.")
            throw TemplateError()
          }

          if copy {
            #if canImport(AppKit)
              NSPasteboard.general.clearContents()
              NSPasteboard.general.setString(templateString, forType: .string)
              logger.info("Copied template to pasteboard.")
            #else
              logger.info("Copying not supported in this context.")
            #endif
          } else {
            logger.info("\(templateString)")
          }

        }

      }
    }
  }
}

extension Template.PathKey: EnumerableFlag {}
