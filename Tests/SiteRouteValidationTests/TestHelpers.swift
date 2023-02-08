import Dependencies
import SiteRouteValidationsLive

func withLiveSiteValidator(operation: @escaping () async throws -> ()) async throws {
  try await withDependencies({ dependencies in
    dependencies.siteValidator = .liveValue
  }, operation: {
    try await operation()
  })
}
