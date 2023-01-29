public struct Validate<Parent, Child>: Validator {
  
  @usableFromInline
  let child: (Parent) -> Child
  
  @usableFromInline
  let childValidator: (Parent) -> any Validator<Child>
  
  @inlinable
  public init(
    toChild child: @escaping (Parent) -> Child,
    childValidator: @escaping (Parent) -> any Validator<Child>
  ) {
    self.child = child
    self.childValidator = childValidator
  }
  
  @inlinable
  public init(
    _ keyPath: KeyPath<Parent, Child>,
    @ValidationBuilder<Child> validator: @escaping (() -> any Validator<Child>)
  ) {
    self.init(
      toChild: { $0[keyPath: keyPath] },
      childValidator: { _ in validator() }
    )
  }
  
  public func validate(_ parent: Parent) async throws {
    try await childValidator(parent).validate(child(parent))
  }
}

extension Validate where Child: Validatable {
  
  @inlinable
  public init(_ toChild: KeyPath<Parent, Child>) {
    self.init(
      toChild: { $0[keyPath: toChild] },
      childValidator: { $0[keyPath: toChild] }
    )
  }
}
