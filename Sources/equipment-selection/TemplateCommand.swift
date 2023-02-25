import AppKit
import ArgumentParser
import Dependencies
import FirstPartyMocks
import Foundation
import Logging
import LoggingDependency
import Models

extension EquipmentSelection {
  struct Template: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
      abstract: "Generate a template file to be used for equipment selection requests."
    )

    @Flag var templateName: InterpolationName
    
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
      try withDependencies {
        if verbose {
          $0.logger.logLevel = .debug
        }
      } operation: {
        @Dependency(\.logger) var logger: Logger
        
        logger.debug("Preparing to \(operationString) template: \(templateName)")
        
        let data = try jsonEncoder.encode(templateName.template)
        if !copy && !echo {
          let path = self.templateName.parseUrl(url: outputPath)
          
          if let outputPath {
            logger.debug("Using path: \(outputPath.absoluteString).")
          } else {
            logger.debug("Using default path: \(path.absoluteString)")
          }
          try data.write(to: path)
          logger.info("Wrote file to path: \(path.absoluteString)")
        } else {
          guard let string = String(data: data, encoding: .utf8) else {
            logger.info("Failed to parse template string.")
            return
          }
          if copy {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(string, forType: .string)
            logger.info("Copied template to pasteboard.")
          } else {
            // don't use a logger here, so that it prints the string without
            // logger metadata.
            print(string)
          }
        }
      }
    }
  }
}
