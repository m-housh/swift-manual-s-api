import Dependencies
import Models
import Validations

/// Handles validations for site routes.
///
public struct ValidationMiddleware {

  /// The actual validator to use.
  @usableFromInline
  let validator: any AsyncValidation<ServerRoute>

  /// Create a new  route validator, that wraps the given validator.
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

extension ValidationMiddleware: TestDependencyKey {

  /// Validator that fails when used.
  public static var testValue: ValidationMiddleware {
    Self.init(AsyncValidator.fail())
  }

  /// A validator that does not perform any validation logic.
  public static var noValidation: ValidationMiddleware {
    Self.init(AsyncValidator.success())
  }
}

extension DependencyValues {

  /// Access a site route validator through the @Dependency values.
  ///
  public var validationMiddleware: ValidationMiddleware {
    get { self[ValidationMiddleware.self] }
    set { self[ValidationMiddleware.self] = newValue }
  }
}
