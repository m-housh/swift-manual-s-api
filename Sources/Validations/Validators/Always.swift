
public struct Always<Value>: Validator {
  @inlinable
  public init() { }
 
  @inlinable
  public func validate(_ value: Value) throws {
    // do nothing.
  }
}
