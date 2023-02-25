import Models
import Validations

// TODO: Need to validate houseLoad, designInfo, seperate of the cooling validations.
extension ServerRoute.Api.Route.Interpolation.Route.Keyed {
  
  @usableFromInline
  func validate(request: ServerRoute.Api.Route.Interpolation) async throws {
    
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

extension Array where Element == ServerRoute.Api.Route.Interpolation.Route.Keyed {
  
  @usableFromInline
  func validate(request: ServerRoute.Api.Route.Interpolation) async throws {
    for keyed in self {
      try await keyed.validate(request: request)
    }
  }
}

extension Array where Element == ServerRoute.Api.Route.Interpolation.Route.Heating {
  
  @usableFromInline
  func validate(request: ServerRoute.Api.Route.Interpolation) async throws {
    for heating in self {
      try await heating.validate(request: request)
    }
  }
}
