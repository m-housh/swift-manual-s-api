import ArgumentParser
import FirstPartyMocks
import Foundation
import Models

extension EquipmentSelection {
  struct Template: AsyncParsableCommand {
    
    static var configuration = CommandConfiguration(
      abstract: "Generate a template file to be used for equipment selection requests."
    )
    
    @Flag var templateName: InterpolationName
    
    @Option(name: .shortAndLong, transform: URL.init(fileURLWithPath:))
    var outputPath: URL?
    
    @Flag var verbose: Bool = false
    
    func run() async throws {
      if verbose {
        print("Preparing to write template: \(templateName)")
      }
      
      let path = self.templateName.parseUrl(url: outputPath)
      
      if let outputPath {
        if verbose {
          print("Using path: \(outputPath.absoluteString).")
        }
      } else {
        if verbose {
          print("Using default path: \(path.absoluteString)")
        }
      }
      let data = try jsonEncoder.encode(templateName.template)
      try data.write(to: path)
      print("Wrote file to path: \(path.absoluteString)")
    }
  }
}

