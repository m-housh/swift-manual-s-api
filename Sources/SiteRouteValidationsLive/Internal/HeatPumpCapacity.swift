import Models
import Validations

@usableFromInline
struct HeatPumpCapacityValidation: AsyncValidation {
  
  @usableFromInline
  typealias Value = HeatPumpCapacity
  
  @usableFromInline
  let errorLabel: any CustomStringConvertible
  
  @usableFromInline
  init(label errorLabel: any CustomStringConvertible) {
    self.errorLabel = errorLabel
  }
  
  @usableFromInline
  var body: some AsyncValidation<Value> {
    AsyncValidator.accumulating {
      AsyncValidator.greaterThan(\.at47, 0)
        .mapError(
          nested: errorLabel, ErrorLabel.at47,
          summary: "Capacity at 47° should be greater than 0."
        )
      AsyncValidator.greaterThan(\.at17, 0)
        .mapError(
          nested: errorLabel, ErrorLabel.at17,
          summary: "Capacity at 47° should be greater than 0."
        )
      AsyncValidator.greaterThanOrEquals(\.at47, \.at17)
        .mapError(
          nested: errorLabel,
          summary: "Capacity at 47° should be greater than or equal to the capacity at 17°."
        )
    }
  }
}
