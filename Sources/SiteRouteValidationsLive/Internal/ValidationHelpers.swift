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
  
  @usableFromInline
  func mapError(
    nested: (any CustomStringConvertible)...,
    summary: String
  ) -> some AsyncValidation<Value> {
    return self.mapError(
      label: ErrorLabel.nest(nested).description,
      summary: summary
    )
  }
  
  @usableFromInline
  func mapError(
    nested: ErrorLabel...,
    summary: String
  ) -> some AsyncValidation<Value> {
    return self.mapError(
      label: ErrorLabel.nest(nested).description,
      summary: summary
    )
  }
  
  @usableFromInline
  func mapError(
    label: any CustomStringConvertible,
    summary: String
  ) -> some AsyncValidation<Value> {
    self.mapError(_ValidationError(label: label, summary: summary))
  }
}

extension RawRepresentable where RawValue == String, Self: CustomStringConvertible {
 
  @usableFromInline
  var description: String { rawValue }
  
}

@usableFromInline
struct _ValidationError: Error, CustomDebugStringConvertible, CustomStringConvertible {
  let label: any CustomStringConvertible
  let summary: String
  
  @usableFromInline
  init(label: any CustomStringConvertible, summary: String) {
    self.label = label
    self.summary = summary
  }
  
  @usableFromInline
  var debugDescription: String {
    "\(label.description): \(summary)"
  }
  
  @usableFromInline
  var description: String { debugDescription }
  
}
