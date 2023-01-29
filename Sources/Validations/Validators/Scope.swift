//
//public struct Scope<Parent, Child>: Validator {
//  
//  @usableFromInline
//  let childKeyPath: KeyPath<Parent, Child>
//  
//  @usableFromInline
//  let childValidator: (any Validator<Child>)?
//  
//  @usableFromInline
//  let parentValidator: ((Parent) -> any Validator<Child>)?
//  
//  @usableFromInline
//  init(
//    toChild childKeyPath: KeyPath<Parent, Child>,
//    childValidator: (any Validator<Child>)?,
//    parentValidator: ((Parent) -> any Validator<Child>)?
//  ) {
//    self.childKeyPath = childKeyPath
//    self.childValidator = childValidator
//    self.parentValidator = parentValidator
//  }
//  
//  @inlinable
//  public init(
//    _ toChild: KeyPath<Parent, Child>,
//    @ValidationBuilder<Child> _ validator: () -> some Validator<Child>
//  ) {
//    self.init(toChild, validator())
//  }
//  
//  @inlinable
//  public init(
//    _ toChild: KeyPath<Parent, Child>,
//    _ validator: some Validator<Child>
//  ) {
//    self.init(
//      toChild: toChild,
//      childValidator: validator,
//      parentValidator: nil
//    )
//  }
//
//  @inlinable
//  public init(
//    _ toChild: KeyPath<Parent, Child>
//  ) where Child: Validator<Child> {
//    self.init(
//      toChild: toChild,
//      childValidator: nil,
//      parentValidator: { $0[keyPath: toChild] }
//    )
//  }
// 
//  @inlinable
//  public func validate(_ parent: Parent) async throws {
//    var validator: any Validator<Child> = Always()
//    
//    if let childValidator = self.childValidator {
//      validator = childValidator
//    } else if let parentValidator = parentValidator {
//      validator = parentValidator(parent)
//    }
//    
//    try await validator.validate(parent[keyPath: childKeyPath])
//  }
//}
//
////extension Scope where Parent == Child {
////  
////  @inlinable
////  public init(_ validator: some Validator<Parent>) {
////    self.init(\.self, validator)
////  }
////  
////  @inlinable
////  public init(@ValidationBuilder<Parent> _ validator: () -> some Validator<Parent>) {
////    self.init(\.self, validator)
////  }
////}
