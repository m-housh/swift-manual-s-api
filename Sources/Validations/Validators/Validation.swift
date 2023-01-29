// TODO: Better name
public struct Validation<Value>: Validator {
  
  @usableFromInline
  let closure: (Value) async throws -> ()
  
  
  @inlinable
  public init<V: Validator>(@ValidationBuilder<Value> _ build: () -> V) where Value == V.Value {
    self.init(build())
  }
  
  @inlinable
  public init(_ validate: @escaping (Value) async throws -> ()) {
    self.closure = validate
  }
  
  @inlinable
  public init<V: Validator>(_ validator: V) where V.Value == Value {
    self.closure = validator.validate(_:)
  }
  
  @inlinable
  public func validate(_ value: Value) async throws {
    try await closure(value)
  }
}

public typealias ValidatorOf<Value> = Validation<Value>
