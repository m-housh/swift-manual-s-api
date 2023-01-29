import Foundation

public protocol Validator<Value> {
  
  associatedtype Value
  
  associatedtype _Body

  typealias Body = _Body
  
  func validate(_ value: Value) async throws

  @ValidationBuilder<Value>
  var body: Body { get }
}

extension Validator where Body == Never {

  @_transparent
  public var body: Body {
    fatalError("\(Self.self) has no body.")
  }
}

extension Validator {
  
  @inlinable
  public var validator: some Validator<Self.Value> {
    Validation(self)
  }
}

extension Validator where Body: Validator, Body.Value == Value {

  @inlinable
  public func validate(_ value: Value) async throws {
    try await self.body.validate(value)
  }
}

// Experiments
public protocol Validatable: Validator where Value == Self {
  func validate() async throws
}

extension Validatable where Self: Validator, Value == Self {
  
  @inlinable
  public func validate() async throws {
    try await self.validate(self)
  }
}
