import Models
import Validations

// TODO: Validate House Load and Adjustment Multipliers
extension ServerRoute.Api.Route.InterpolationRequest.Heating.BoilerRequest: AsyncValidatable {
  
  @inlinable
  public var body: some AsyncValidation<Self> {
    AsyncValidator.accumulating {
      AsyncValidator.validate(\.afue) {
        Double.greaterThan(0)
        Double.lessThanOrEquals(100)
      }
      .mapError(
        label: ErrorLabel.afue,
        summary: "Afue should be greater than 0 or less than 100."
      )
      
      AsyncValidator.validate(\.input, with: .greaterThan(0))
        .mapError(
          label: ErrorLabel.input,
          summary: "Input should be greater than 0."
        )
      
      AsyncValidator.validate(
        \.houseLoad,
         with: HouseLoadValidator(style: .heating)
      )
      
      AsyncValidator.validate(
        \.altitudeDeratings,
         with: AdjustmentMultiplierValidation(style: .heating, label: ErrorLabel.altitudeDeratings).optional()
      )
      
    }
    .errorLabel("Boiler Request Errors")
  }
}

// TODO: Validate House Load and Adjustment Multipliers
extension ServerRoute.Api.Route.InterpolationRequest.Heating.FurnaceRequest: AsyncValidatable {
  
  @inlinable
  public var body: some AsyncValidation<Self> {
    AsyncValidator.accumulating {
      AsyncValidator.validate(\.afue) {
        Double.greaterThan(0)
        Double.lessThanOrEquals(100)
      }
      .mapError(
        label: ErrorLabel.afue,
        summary: "Afue should be greater than 0 or less than 100."
      )
      
      AsyncValidator.validate(\.input, with: .greaterThan(0))
        .mapError(
          label: ErrorLabel.input,
          summary: "Input should be greater than 0."
        )
      
      
      AsyncValidator.validate(
        \.houseLoad,
         with: HouseLoadValidator(style: .heating)
      )
      
      AsyncValidator.validate(
        \.altitudeDeratings,
         with: AdjustmentMultiplierValidation(style: .heating, label: ErrorLabel.altitudeDeratings).optional()
      )
    }
    .errorLabel("Furnace Request Errors")
  }
}
