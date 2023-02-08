import Validations

extension AsyncValidation {
  
  @usableFromInline
  func errorLabel<S: CustomStringConvertible>(
    label: S,
    inline: Bool = false
  )
  -> some AsyncValidation<Value>
  {
    self.errorLabel(label.description, inline: inline)
  }
  
//  @usableFromInline
//  func mapError(
//    labels: CommonErrorLabel,
//    summary: String
//  ) -> some AsyncValidation<Value> {
//    self.mapError(_ValidationError(labels: labels, summary: summary))
//  }
//
//  @usableFromInline
//   func mapError(
//    parenthesized: [(any CustomStringConvertible)],
//    nested: [(any CustomStringConvertible)],
//    summary: String
//  )
//  -> some AsyncValidation<Value>
//  {
//    self.mapError(labels: .nested(parenthesized: parenthesized, nested: nested), summary: summary)
//  }
  
  @usableFromInline
  func mapError(
    nested: (any CustomStringConvertible)...,
    summary: String
  ) -> some AsyncValidation<Value> {
    return self.mapError(
      label: AnyErrorLabel.nest(nested).description,
      summary: summary
    )
  }
  
  
  @usableFromInline
  func mapError(
    label: any CustomStringConvertible,
    summary: String
  ) -> some AsyncValidation<Value> {
    self.mapError(_ValidationError(labels: .nested(label), summary: summary))
  }
}

extension RawRepresentable where RawValue == String, Self: CustomStringConvertible {
 
  @usableFromInline
  var description: String { rawValue }
  
}

@usableFromInline
struct _CommonErrorValidator<Upstream: AsyncValidation>: AsyncValidation {
  @usableFromInline
  let labels: CommonErrorLabel

  @usableFromInline
  let upstream: Upstream

  @usableFromInline
  init(upstream: Upstream, labels: CommonErrorLabel) {
    self.labels = labels
    self.upstream = upstream
  }

  @usableFromInline
  func validate(_ value: Upstream.Value) async throws {
    do {
      try await self.upstream.validate(value)
    } catch {
      throw CommonError(labels: labels, underlyingError: error)
    }
  }
}

@usableFromInline
struct CommonError: Error {
  let labels: CommonErrorLabel
  let underlyingError: Error
}

extension CommonError: CustomDebugStringConvertible {
  @usableFromInline
  var debugDescription: String {
    let errorString = (underlyingError as CustomDebugStringConvertible).debugDescription
    if !labels.description.isEmpty {
      return "\(labels): \(errorString)"
    }
    return errorString
  }
}

// TODO: Remove

@usableFromInline
enum CommonErrorLabel: CustomStringConvertible {
  case parenthesize([any CustomStringConvertible])
  case nested(parenthesized: [any CustomStringConvertible], nested: [any CustomStringConvertible])
  
  @usableFromInline
  var description: String {
    switch self {
    case let .parenthesize(values):
      guard values.count > 0 else { return "" }
      let valueString = values.map { $0.description }.joined(separator: ", ")
      return "(\(valueString))"
    case let .nested(parenthesized, nested):
      var nestedString = ""
      if !nested.isEmpty {
        nestedString = nested.map({ $0.description }).joined(separator: ".")
      }
      guard parenthesized.count >  0 else {
        return nestedString
      }
      let parenthesizedString = Self.parenthesize(parenthesized).description
      return "\(parenthesizedString)\(nestedString.isEmpty ? "" : ".\(nestedString)")"
    }
  }
  
  @usableFromInline
  static func nested(_ values: (any CustomStringConvertible)...) -> Self {
    return .nested(parenthesized: [], nested: values)
  }

}

protocol ErrorLabelType: CustomStringConvertible { }

extension ErrorLabelType {
  
  @inlinable
  public static func nest(_ values: Self...) -> String {
    values.map { $0.description }.joined(separator: ".")
  }
  
  @inlinable
  public static func nest(_ values: (any CustomStringConvertible)...) -> String {
    values.map { $0.description }.joined(separator: ".")
  }
  
  @inlinable
  public static func parenthesize(_ values: Self...) -> String {
    let inner = values.map { $0.description }.joined(separator: ", ")
    return "(\(inner))"
  }
  
  @inlinable
  public static func parenthesize(_ values: (any CustomStringConvertible)...) -> String {
    let inner = values.map { $0.description }.joined(separator: ", ")
    return "(\(inner))"
  }
}

@usableFromInline
struct AnyErrorLabel: ErrorLabelType {
  @usableFromInline
  let label: any CustomStringConvertible
  
  @usableFromInline
  var description: String { label.description }
}

@usableFromInline
struct _ValidationError: Error, CustomDebugStringConvertible, CustomStringConvertible {
  let labels: CommonErrorLabel
  let summary: String
  
  @usableFromInline
  init(labels: CommonErrorLabel, summary: String) {
    self.labels = labels
    self.summary = summary
  }
  
  @usableFromInline
  var debugDescription: String {
    "\(labels.description): \(summary)"
  }
  
  @usableFromInline
  var description: String { debugDescription }
  
}
