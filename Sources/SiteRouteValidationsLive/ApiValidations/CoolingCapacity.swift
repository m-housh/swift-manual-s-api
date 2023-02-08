import Models
import Validations

@usableFromInline
struct CoolingCapacityValidation: AsyncValidation {

  @usableFromInline
  typealias Value = CoolingCapacity
  
  @usableFromInline
  let errorLabel: any CustomStringConvertible
  
  @usableFromInline
  init(errorLabel: any CustomStringConvertible) {
    self.errorLabel = errorLabel
  }
  
  @usableFromInline
  enum ErrorLabel: String, ErrorLabelType {
    case total
    case sensible
  }
  
  @usableFromInline
  var body: some AsyncValidation<CoolingCapacity> {
    AsyncValidator.accumulating {
      AsyncValidator.validate(\.total, with: .greaterThan(0))
        .mapError(
          label: ErrorLabel.nest(errorLabel, ErrorLabel.total),
          summary: "Total capacity should be greater than 0"
        )
      AsyncValidator.validate(\.sensible, with: .greaterThan(0))
        .mapError(
          label: ErrorLabel.nest(errorLabel, ErrorLabel.sensible),
          summary: "Sensible capacity should be greater than 0"
        )
    }
  }
}
