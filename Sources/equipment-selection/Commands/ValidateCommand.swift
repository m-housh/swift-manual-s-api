import ArgumentParser
import CliMiddleware
import Dependencies
import Foundation
import Models

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension EquipmentSelection {

  struct Validate: AsyncParsableCommand {
    static let configuration: CommandConfiguration = .init(
      abstract: "Validate a file / template."
    )

    @Flag(help: "The file / template type to validate.")
    var key: Models.Template.PathKey = .project

    @Argument(
      help: """
        The optional input file to validate, if not supplied we will
        search using the default filename for the given key.
        """,
      transform: URL.init(fileURLWithPath:)
    )
    var inputFile: URL?

    @OptionGroup
    var globalOptions: GlobalOptions
    
    func run() async throws {
      try await CliContext(globalOptions: globalOptions) {
        @Dependency(\.cliMiddleware.validate) var validate
        try await validate(.init(key: self.key, inputFile: self.inputFile))
      }
      .run()
    }
  }
}
