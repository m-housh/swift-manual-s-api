import ApiClientLive
import ArgumentParser
import CliMiddlewareLive
import Dependencies
import Foundation
import LoggingDependency
import Models
import SettingsClientLive
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

  // These overrides, except for log level, are unnecessary when built for release,
  // however they're needed when invoking with `swift run equipment-selection ...`
  // which builds and runs in debug mode.
  func run() async throws {
    try await withDependencies {
      $0.logger = .cliLogger
      if globalOptions.verbose {
        $0.logger.logLevel = .debug
      }
      $0.settingsClient = .liveValue
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
