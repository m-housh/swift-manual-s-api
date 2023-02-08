import Models
import Validations
import Dependencies

/// Handles validations for site routes.
///
public struct SiteRouteValidator {
  
  /// The actual validator to use.
  @usableFromInline
  let validator: any AsyncValidation<ServerRoute>
  
  /// Create a new site route validator, that wraps the given validator.
  ///
  /// - Parameters:
  ///   - validator: The validator to use for route validations.
  @inlinable
  public init(_ validator: any AsyncValidation<ServerRoute>) {
    self.validator = validator
  }
  
  /// Create a new site route validator, that wraps the given closure for validating routes.
  ///
  /// - Parameters:
  ///   - validator: The validator to use for route validations.
  @inlinable
  public init(_ validator: @escaping (ServerRoute) async throws -> Void) {
    self.validator = AnyAsyncValidator(validator)
  }
  
  /// Validate a server route or throw errors if it is invalid.
  ///
  /// - Parameters:
  ///   - route: The server route to validate.
  @inlinable
  public func validate(_ route: ServerRoute) async throws {
    try await self.validator.validate(route)
  }
}

extension SiteRouteValidator: TestDependencyKey {
  
  /// Validator that fails when used.
  public static var testValue: SiteRouteValidator = Self.init(AsyncValidator.fail())
  
  /// A validator that does not perform any validation logic.
  public static var noValidation = Self.init(AsyncValidator.success())
}

extension DependencyValues {

  /// Access a site route validator through the @Dependency values.
  ///
  public var siteValidator: SiteRouteValidator {
    get { self[SiteRouteValidator.self] }
    set { self[SiteRouteValidator.self] = newValue }
  }
}

/// Handles validations for api routes.
///
public struct ApiRouteValidator: TestDependencyKey {
  
  /// The actual validator to use.
  @usableFromInline
  let validator: any AsyncValidation<ServerRoute.Api.Route>
  
  /// Create a new api route validator, that wraps the given validator.
  ///
  /// - Parameters:
  ///   - validator: The validator to use for route validations.
  @inlinable
  public init(_ validator: any AsyncValidation<ServerRoute.Api.Route>) {
    self.validator = validator
  }
  
  /// Create a new api route validator, that wraps the given closure for validating routes.
  ///
  /// - Parameters:
  ///   - validator: The validator to use for route validations.
  @inlinable
  public init(_ validator: @escaping (ServerRoute.Api.Route) async throws -> Void) {
    self.validator = AnyAsyncValidator(validator)
  }
  
  /// Validate an api route or throw errors if it is invalid.
  ///
  /// - Parameters:
  ///   - route: The api route to validate.
  @inlinable
  public func validate(_ route: ServerRoute.Api.Route) async throws {
    try await self.validator.validate(route)
  }
  
  public static let testValue = Self.init(AsyncValidator.fail())
}
