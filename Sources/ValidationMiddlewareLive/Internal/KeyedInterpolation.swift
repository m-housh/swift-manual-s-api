import Models
import Validations

#warning("Need a project validation.")
// TODO: Need to validate houseLoad, designInfo, seperate of the cooling validations.
extension Project.System {

  @usableFromInline
  func validate(request: ServerRoute.Api.Route.Interpolation.SingleInterpolation) async throws {

    try await AsyncValidator.accumulating {
      AnyAsyncValidator {
        try await self.cooling.validate(request: request)
      }
      AnyAsyncValidator {
        try await heating.validate(request: request)
      }
    }
    .validate(())
  }
}

extension Array where Element == Project.System {

  @usableFromInline
  func validate(request: ServerRoute.Api.Route.Interpolation.SingleInterpolation) async throws {
    for system in self {
      try await system.validate(request: request)
    }
  }
}

extension Array where Element == ServerRoute.Api.Route.Interpolation.SingleInterpolation.Route.Heating {

  @usableFromInline
  func validate(request: ServerRoute.Api.Route.Interpolation.SingleInterpolation) async throws {
    for heating in self {
      try await heating.validate(request: request)
    }
  }
}
