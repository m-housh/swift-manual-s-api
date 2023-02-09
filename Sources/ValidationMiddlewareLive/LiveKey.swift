import Dependencies
import Models
@_exported import ValidationMiddleware
import Validations

/// Handles validations for api routes.
///
@usableFromInline
struct ApiRouteValidator {

  /// The actual validator to use.
  @usableFromInline
  let validator: any AsyncValidation<ServerRoute.Api.Route>

  /// Create a new api route validator, that wraps the given validator.
  ///
  /// - Parameters:
  ///   - validator: The validator to use for route validations.
  @usableFromInline
  init(_ validator: any AsyncValidation<ServerRoute.Api.Route>) {
    self.validator = validator
  }

  /// Create a new api route validator, that wraps the given closure for validating routes.
  ///
  /// - Parameters:
  ///   - validator: The validator to use for route validations.
  @usableFromInline
  init(_ validator: @escaping (ServerRoute.Api.Route) async throws -> Void) {
    self.validator = AnyAsyncValidator(validator)
  }

  /// Validate an api route or throw errors if it is invalid.
  ///
  /// - Parameters:
  ///   - route: The api route to validate.
  @usableFromInline
  func validate(_ route: ServerRoute.Api.Route) async throws {
    try await self.validator.validate(route)
  }
}

extension ApiRouteValidator {
  @usableFromInline
  static var liveValue: ApiRouteValidator = .init { route in
    switch route {
    case let .balancePoint(balancePoint):
      return try await balancePoint.validate()
    case .derating(_):
      // no validations required.
      return
    case let .interpolate(interpolate):
      return try await interpolate.validate()
    case let .requiredKW(requiredKW):
      return try await requiredKW.validate()
    case let .sizingLimits(sizingLimits):
      return try await sizingLimits.validate()
    }
  }
}

extension ValidationMiddleware: DependencyKey {

  @inlinable
  public static var liveValue: ValidationMiddleware {
    .init { route in

      let apiRouteValidator = ApiRouteValidator.liveValue

      switch route {
      case .home:
        // no validations required.
        return
      case let .api(api):
        return try await apiRouteValidator.validate(api.route)
      }
    }
  }

}
