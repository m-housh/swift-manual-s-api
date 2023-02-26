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

    static var configuration = CommandConfiguration(
      abstract: "Generate a template file to be used for equipment selection requests."
    )

    @Flag
    var templateName: CliMiddleware.InterpolationName = .keyed

    @Flag var copy: Bool = false

    @Flag(inversion: .prefixedNo)
    var echo: Bool = true

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
        $0.logger = logger
        if verbose {
          $0.logger.logLevel = .debug
        }
      } operation: {
        @Dependency(\.cliMiddleware) var cliMiddleware: CliMiddleware
        @Dependency(\.logger) var logger: Logger

        logger.debug("Preparing to \(operationString) template: \(templateName)")

        let data = try await cliMiddleware.template(templateName)
        if let outputPath {
          let path = self.templateName.parseUrl(url: outputPath)
          logger.debug("Using path: \(path.absoluteString).")
          try data.write(to: path)
          logger.info("Wrote file to path: \(path.absoluteString)")
        } else {
          guard let string = String(data: data, encoding: .utf8) else {
            logger.info("Failed to parse template string.")
            return
          }
          if copy {
            #if canImport(AppKit)
              NSPasteboard.general.clearContents()
              NSPasteboard.general.setString(string, forType: .string)
              logger.info("Copied template to pasteboard.")
            #else
              logger.info("Copying not supported in this context.")
            #endif
          } else {
            logger.info("\(string)")
          }
        }
      }
    }
  }
}
