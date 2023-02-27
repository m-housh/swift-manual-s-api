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

    @Flag
    var templateKey: Template.PathKey = .keyed

    @Flag(inversion: .prefixedNo)
    var copy: Bool = false

    @Flag(inversion: .prefixedNo)
    var echo: Bool = true

    @Flag(name: [.long, .customShort("i")])
    var embedInInterpolation: Bool = false

    @Flag(name: [.long, .customShort("r")])
    var embedInRoute: Bool = false

    @Option(name: .shortAndLong, transform: URL.init(fileURLWithPath:))
    var outputPath: URL?

    @Flag var verbose: Bool = false

    var operationString: String {
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
          let route = try await templateClient.routeTemplate(for: templateKey)
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
