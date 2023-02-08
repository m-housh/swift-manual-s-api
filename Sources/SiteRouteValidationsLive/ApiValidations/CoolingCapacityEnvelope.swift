import Models
import Validations

@usableFromInline
struct CoolingCapacityEnvelopeValidation: AsyncValidation {
  @usableFromInline
  typealias Value = CoolingCapacityEnvelope
  
  @usableFromInline
  let errorLabel: any CustomStringConvertible
  
  @usableFromInline
  enum ErrorLabel: String, ErrorLabelType {
    case cfm
    case capacity
    case indoorTemperature
  }
  
  @usableFromInline
  var body: some AsyncValidation<CoolingCapacityEnvelope> {
    AsyncValidator.accumulating {
      AsyncValidator.greaterThan(\.cfm, 0)
        .mapError(
          label: ErrorLabel.nest(errorLabel, ErrorLabel.cfm),
          summary: "Cfm should be greater than 0."
        )
      
      AsyncValidator.greaterThan(\.indoorTemperature, 0)
        .mapError(
          label: ErrorLabel.nest(errorLabel, ErrorLabel.indoorTemperature),
          summary: "Indoor temperature should be greater than 0."
        )

      AsyncValidator.validate(
        \.capacity,
         with: CoolingCapacityValidation(
          errorLabel: ErrorLabel.nest(errorLabel, ErrorLabel.capacity)
         )
      )

    }
  }
}
