import Models
import Validations

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

//      AsyncValidator.validate(
//        \.altitudeDeratings,
//        with: AdjustmentMultiplierValidation(style: .heating, label: ErrorLabel.altitudeDeratings)
//          .optional()
//      )

    }
    .errorLabel("Boiler Request Errors")
  }
}

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

//      AsyncValidator.validate(
//        \.altitudeDeratings,
//        with: AdjustmentMultiplierValidation(style: .heating, label: ErrorLabel.altitudeDeratings)
//          .optional()
//      )
    }
    .errorLabel("Furnace Request Errors")
  }
}

extension ServerRoute.Api.Route.InterpolationRequest.Heating.ElectricRequest: AsyncValidatable {

  @inlinable
  public var body: some AsyncValidation<Self> {
    AsyncValidator.accumulating {
      AsyncValidator.validate(\.inputKW, with: .greaterThan(0))
        .mapError(
          label: ErrorLabel.inputKW,
          summary: "Input KW should be greater than 0."
        )

      AsyncValidator.validate(
        \.houseLoad,
        with: HouseLoadValidator(style: .heating)
      )

//      AsyncValidator.validate(
//        \.altitudeDeratings,
//        with: AdjustmentMultiplierValidation(style: .heating, label: ErrorLabel.altitudeDeratings)
//          .optional()
//      )

      AsyncValidator.validate(
        \.heatPumpCapacity,
        with: Int.greaterThan(0).async().optional()
      )
      .mapError(
        label: ErrorLabel.heatPumpCapacity,
        summary: "Heat pump capacity should be greater than 0."
      )
    }
    .errorLabel("Electric Request Errors")
  }
}

extension ServerRoute.Api.Route.InterpolationRequest.Heating.HeatPumpRequest: AsyncValidatable {

  @inlinable
  public var body: some AsyncValidation<Self> {
    AsyncValidator.accumulating {
//      AsyncValidator.validate(
//        \.altitudeDeratings,
//        with: AdjustmentMultiplierValidation(style: .heating, label: ErrorLabel.altitudeDeratings)
//          .optional()
//      )

      AsyncValidator.validate(
        \.capacity, with: HeatPumpCapacityValidation(label: ErrorLabel.capacity))

      AsyncValidator.validate(\.houseLoad, with: HouseLoadValidator(style: .heating))

    }
    .errorLabel("Heat Pump Request Errors")
  }
}
