import Dependencies
import Models
import Validations

public struct ValidationMiddleware {
  
  public let validator: any AsyncValidation<ServerRoute>
  
  @inlinable
  public init(validator: any AsyncValidation<ServerRoute>) {
    self.validator = validator
  }
  
  @inlinable
  public init(
    @AsyncValidationBuilder<ServerRoute> validator: @escaping () -> any AsyncValidation<ServerRoute>
  ) {
    self.validator = validator()
  }
  
  public func validate(_ route: ServerRoute) async throws {
    try await validator.validate(route)
  }
  
}

