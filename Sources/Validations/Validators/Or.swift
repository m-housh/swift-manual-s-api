
public struct _Or<Validate: Validator>: Validator {
  
  public typealias Value = Validate.Value
  
  @usableFromInline
  let lhs: Validate
  
  @usableFromInline
  let rhs: any Validator<Value>
  
  @inlinable
  public init(_ lhs: Validate, _ rhs: some Validator<Value>) {
    self.lhs = lhs
    self.rhs = rhs
  }
  
  public func validate(_ value: Validate.Value) async throws {
    do {
      try await lhs.validate(value)
    } catch {
      try await rhs.validate(value)
    }
  }
}

extension Validator {
  
  public func or(_ other: some Validator<Self.Value>) -> some Validator<Value> {
    _Or(self, other)
  }
  
  public func or(@ValidationBuilder<Self.Value> _ build: () -> some Validator<Self.Value>) -> some Validator<Value> {
    _Or(self, build())
  }
}
