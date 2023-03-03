import ArgumentParser
import CliMiddleware
import Dependencies
import Foundation
import Models

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

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
    var templateKey: Template.PathKey = .project

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

    func run() async throws {
      try await CliContext(globalOptions: globalOptions) {
        try await withDependencies {
          $0.json.jsonEncoder = .factory(.prettyPrinted)
        } operation: {
          @Dependency(\.cliMiddleware.templates) var templates
          try await templates(
            .template(
              key: templateKey,
              embedIn: embedInContext,
              outputContext: outputContext
            )
          )
        }
      }.run()
    }

    private var outputContext: CliMiddleware.TemplateContext.Template.OutputContext {
      if let outputPath {
        return .write(to: outputPath)
      } else if copy {
        return .copy
      }
      return .echo
    }

    private var embedInContext: CliMiddleware.TemplateContext.Template.EmbedInContext? {
      if embedInRoute {
        return .route
      } else if embedInInterpolation {
        return .interpolation
      }
      return nil
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
        @Dependency(\.cliMiddleware.templates) var templates
        try await templates(.generate)
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
        @Dependency(\.cliMiddleware.templates) var templates
        try await templates(.remove(force: force))
      }
      .run()
    }
  }
}
