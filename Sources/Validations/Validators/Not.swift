
/// Inverses a validator.
public struct Not<Validate: Validator>: Validator {
  
  public typealias Value = Validate.Value
  
  @usableFromInline
  let validator: Validate
  
  @inlinable
  public init(_ validator: Validate) {
    self.validator = validator
  }
  
  @inlinable
  public init(@ValidationBuilder<Validate.Value> _ build: () -> Validate) {
    self.validator = build()
  }
  
  @inlinable
  public func validate(_ value: Validate.Value) async throws {
    do {
      // should throw an error.
      try await self.validator.validate(value)
    } catch {
      // happy path.
      return
    }
    throw ValidationError(message: "Not validator did not succeed.")
  }
}
