import Models
import Validations

@usableFromInline
struct AdjustmentMultiplierValidation: AsyncValidation {
  @usableFromInline
  typealias Value = AdjustmentMultiplier
  
 
  @usableFromInline
  let style: Style
  
  @usableFromInline
  let errorLabel: any CustomStringConvertible
  
  @usableFromInline
  init(style: Style, label errorLabel: any CustomStringConvertible) {
    self.style = style
    self.errorLabel = errorLabel
  }
  
  @usableFromInline
  enum Style {
    case cooling
    case heating
  }
   
  @usableFromInline
  func validate(_ value: AdjustmentMultiplier) async throws {
    struct CoolingEnvelope {
      let total: Double
      let sensible: Double
    }
    
    switch style {
    case .cooling:
      switch value {
      case let .airToAir(total: total, sensible: sensible, heating: _):
        try await AsyncValidatorOf<CoolingEnvelope>.accumulating {
          AsyncValidator.validate(\.total, with: .greaterThan(0))
            .mapError(
              nested: errorLabel, ErrorLabel.total,
              summary: "Total adjustment multiplier should be greater than 0."
            )
          AsyncValidator.validate(\.sensible, with: .greaterThan(0))
            .mapError(
              nested: errorLabel, ErrorLabel.sensible,
              summary: "Sensible adjustment multiplier should be greater than 0."
            )
        }
        .validate(.init(total: total, sensible: sensible))
      case .heating:
        return // throw errors?
      }
    case .heating:
      let heatingValue: Double
      switch value {
      case let .airToAir(total: _, sensible: _, heating: heating):
        heatingValue = heating
      case let .heating(heating):
        heatingValue = heating
      }
      try await AsyncValidatorOf<Double>.greaterThan(0)
        .mapError(
          label: errorLabel,
          summary: "Heating adjustment multiplier should be greater than 0."
        )
        .validate(heatingValue)
    }
  }
  
}
