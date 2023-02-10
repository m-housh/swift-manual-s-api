import Foundation
import Models
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
    self.mapError(ValidationError(label: label, summary: summary))
  }
}

extension RawRepresentable where RawValue == String, Self: CustomStringConvertible {

  @usableFromInline
  var description: String { rawValue }

}

