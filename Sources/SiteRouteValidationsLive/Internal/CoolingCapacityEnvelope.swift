import Models
import Validations

@usableFromInline
struct CoolingCapacityEnvelopeValidation: AsyncValidation {
  @usableFromInline
  typealias Value = CoolingCapacityEnvelope
  
  @usableFromInline
  let errorLabel: any CustomStringConvertible
  
  @usableFromInline
  init(errorLabel: any CustomStringConvertible) {
    self.errorLabel = errorLabel
  }
  
  @usableFromInline
  var body: some AsyncValidation<CoolingCapacityEnvelope> {
    AsyncValidator.accumulating {
      AsyncValidator.greaterThan(\.cfm, 0)
        .mapError(
          nested: errorLabel, ErrorLabel.cfm,
          summary: "Cfm should be greater than 0."
        )
      
      AsyncValidator.greaterThan(\.indoorTemperature, 0)
        .mapError(
          nested: errorLabel, ErrorLabel.indoorTemperature,
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
