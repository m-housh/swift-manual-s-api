import Dependencies
import Foundation
import SiteRouteValidationsLive

func withLiveSiteValidator(operation: @escaping () async throws -> ()) async throws {
  try await withDependencies({ dependencies in
    dependencies.siteValidator = .liveValue
  }, operation: {
    try await operation()
  })
}


func errorString(_ error: Error) -> String {
  if let e = error as? _ValidationError {
    return e.description
  } else if let e = error as? LocalizedError {
    return e.localizedDescription
  } else {
    return "\(error)"
  }
}
