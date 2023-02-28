import ArgumentParser
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
      commandName: "templates",
      abstract: "Commands for working with the templates system.",
      subcommands: [
        GenerateTemplatesCommand.self,
        RemoveTemplatesCommand.self,
        TemplateCommand.self,
      ],
      defaultSubcommand: TemplateCommand.self
    )
  }
}

extension EquipmentSelection.Template {

  struct TemplateCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(
      commandName: "template",
      abstract: "Generate a local template value or file."
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
      help: "Print the template to standard-output."
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
    
    @OptionGroup var globalOptions: GlobalOptions
    
    // Represents the operation string, used for verbose logging.
    private var operationString: String {
      if copy { return "copy" }
      if !copy && !echo { return "write" }
      return "echo"
    }

    func run() async throws {
      try await CliContext(globalOptions: globalOptions) {
        try await withDependencies {
          $0.templateClient = .live(jsonEncoder: .cliEncoder(.prettyPrinted))
        } operation: {
          @Dependency(\.configClient) var configClient
          @Dependency(\.fileClient) var fileClient
          @Dependency(\.jsonCoders.jsonEncoder) var jsonEncoder
          @Dependency(\.logger) var logger
          @Dependency(\.templateClient) var templateClient
          
          let templateData: Data
          
          if !embedInRoute {
            templateData = try await templateClient.template(
              for: templateKey,
              inInterpolation: embedInInterpolation
            )
          } else {
            
            // convert the template key to an embeddable key or fail if an invalid type.
            guard let embeddableKey = Template.EmbeddableKey(rawValue: templateKey.rawValue) else {
              struct NotEmbeddableError: Error {}
              throw NotEmbeddableError()
            }
            
            // Don't include the route name for certain templates that are generally embedded inside
            // a keyed interpolation.  This allows for using the templated value inside of a vim
            // buffer more easily.
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
          
          // Check if the caller wants a file to be written.
          if let outputPath {
            let fileName = config.templatePaths.fileName(for: templateKey)
            let outputUrl = outputPath.appendingPathComponent(fileName)
            try await fileClient.write(data: templateData, to: outputUrl)
            logger.info("Wrote template to: \(outputUrl.absoluteString)")
            return
          } else {
            // Do not write to a file, instead echo or copy the template.
            
            // Create a string from the template data.
            guard let templateString = String(data: templateData, encoding: .utf8) else {
              struct TemplateError: Error {}
              logger.info("Failed to parse template string.")
              throw TemplateError()
            }
            
            if copy {
              // Copy to the clip board if the platform supports it.
              #if canImport(AppKit)
              NSPasteboard.general.clearContents()
              NSPasteboard.general.setString(templateString, forType: .string)
              logger.info("Copied template to pasteboard.")
              return
              #else
              logger.info("Copying not supported in this context.")
              #endif
            }
            
            // Log output to console if not able to copy or `echo` was selected.
            logger.info("\(templateString)")
            
          }
        }
      }.run()
    }
  }
  
  struct GenerateTemplatesCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(
      commandName: "generate",
      abstract: "Generate local template files to be used for customizing templates."
    )
    
    @OptionGroup var globalOptions: GlobalOptions

    func run() async throws {
      try await CliContext(globalOptions: globalOptions) {
        @Dependency(\.templateClient) var templateClient
        @Dependency(\.logger) var logger
        
        let templatesPath = templateClient.templateDirectory()
        try await templateClient.generateTemplates()
        logger.info("Wrote templates to path: \(templatesPath.absoluteString)")
      }
      .run()
    }
  }
  
  struct RemoveTemplatesCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(
      commandName: "remove",
      abstract: "Remove local template files."
    )
    
    @Flag(
      name: .shortAndLong,
      help: "Do not prompt before removing templates directory."
    )
    var force: Bool = false
    
    @OptionGroup var globalOptions: GlobalOptions

    func run() async throws {
      try await CliContext(globalOptions: globalOptions) {
        @Dependency(\.templateClient) var templateClient
        @Dependency(\.logger) var logger
        
        let templatesPath = templateClient.templateDirectory()
        
        if !force {
          logger.info("This will delete template files from: \(templatesPath.absoluteString)")
          logger.info("Would you like to continue: [y/n]?")
          guard let answer = readLine(),
                let character = answer.lowercased().first
          else {
            logger.info("Did not recieve an answer, aborting.")
            return
          }
          switch character {
          case "y":
            break
          default:
            logger.info("Did not recieve a yes, not deleting templates.")
            return
          }
        }
        
        // recieved a yes or the `--force` flag was called.
        try await templateClient.removeTemplateDirectory()
        logger.info("Deleted templates at path: \(templatesPath.absoluteString)")
      }
      .run()
    }
  }
}
