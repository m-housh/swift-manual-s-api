import Dependencies
import FirstPartyMocks
import Foundation
import JsonDependency
import LoggingDependency
import Models
import TemplateClient

#if canImport(AppKit)
  import AppKit
#endif

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension CliMiddleware.TemplateContext {

  @Sendable
  static func run(context: Self) async throws {
    switch context {
    case .generate:
      try await generate()
    case .remove(let force):
      try await removeTemplates(force: force)
    case .template(let context):
      try await template(context: context)
    }
  }

  fileprivate static func generate() async throws {
    @Dependency(\.templateClient) var templateClient
    @Dependency(\.logger) var logger

    let templatePath = templateClient.templateDirectory()
    try await templateClient.generateTemplates()
    logger.info(
      "Wrote templates to path: \(templatePath.absoluteString)"
    )
  }

  fileprivate static func removeTemplates(force: Bool) async throws {
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
      case "n":
        logger.info("Did not recieve a yes, not deleting templates.")
        return
      default:
        break
      }
    }

    // recieved a yes or the `--force` flag was called.
    try await templateClient.removeTemplateDirectory()
    logger.info(
      "Deleted templates at path: \(templatesPath.absoluteString)"
    )
  }

  fileprivate static func template(context: Template) async throws {
    @Dependency(\.configClient) var configClient
    @Dependency(\.fileClient) var fileClient
    @Dependency(\.json.jsonEncoder) var jsonEncoder
    @Dependency(\.logger) var logger
    @Dependency(\.templateClient) var templateClient

    let templateData: Data

    if !(context.embedIn == .route) {
      templateData = try await templateClient.template(
        for: context.key.templateKeyPath,
        inInterpolation: context.embedIn == .interpolation
      )
    } else {

      // convert the template key to an embeddable key or fail if an invalid type.
      guard let embeddableKey = context.key.embeddableKey else {
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

    let config = await configClient.config()

    // Check if the caller wants a file to be written.
    if case let .write(to: outputPath) = context.outputContext {
      let fileName = config.templatePaths.fileName(for: context.key)
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

      if context.outputContext == .copy {
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
}
