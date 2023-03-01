import ApiClientLive
import ArgumentParser
import CliMiddlewareLive
import ClientConfigLive
import Dependencies
import Foundation
import LoggingDependency
import Models
import TemplateClientLive
import ValidationMiddlewareLive

struct GlobalOptions: ParsableArguments {
  @Flag(
    name: .shortAndLong,
    help: "Increase logging output."
  )
  var verbose = false
}

// Sets up the default live dependencies for commands.
struct CliContext {
  let globalOptions: GlobalOptions
  let _run: () async throws -> Void

  init(
    globalOptions: GlobalOptions,
    run: @escaping () async throws -> Void
  ) {
    self.globalOptions = globalOptions
    self._run = run
  }

  func run() async throws {
    try await withDependencies {
      $0.logger = .cliLogger
      if globalOptions.verbose {
        $0.logger.logLevel = .debug
      }
      $0.configClient = .liveValue
      $0.templateClient = .liveValue
      $0.json = .liveValue
      $0.apiClient = .liveValue
      $0.validationMiddleware = .liveValue
      $0.cliMiddleware = .liveValue
    } operation: {
      try await self._run()
    }
  }
}
