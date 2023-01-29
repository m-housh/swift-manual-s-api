
public struct Equals<Value, Element: Equatable>: Validator {
  
  @usableFromInline
  let lhs: (Value) -> Element
  
  @usableFromInline
  let rhs: (Value) -> Element
  
  @inlinable
  public init(
    _ lhs: @escaping (Value) -> Element,
    _ rhs: @escaping (Value) -> Element
  ) {
    self.lhs = lhs
    self.rhs = rhs
  }
 
  @inlinable
  public init(
    _ lhs: KeyPath<Value, Element>,
    _ rhs: KeyPath<Value, Element>
  ) {
    self.init({ $0[keyPath: lhs] }, { $0[keyPath: rhs] })
  }
  
  @inlinable
  public init(
    _ lhs: KeyPath<Value, Element>,
    _ rhs: Element
  ) {
    self.init({ $0[keyPath: lhs] }, { _ in rhs })
  }
  
  @inlinable
  public func validate(_ value: Value) throws {
    let lhs = self.lhs(value)
    let rhs = self.rhs(value)
    
    guard lhs == rhs else {
      throw ValidationError(message: "\(lhs) is not equal to \(rhs)")
    }
  }
  
}

extension Equals where Value == Element {
  
  @inlinable
  public init(_ rhs: Element) {
    self.init(\.self, rhs)
  }
}

