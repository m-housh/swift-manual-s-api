import Models
import Validations

@usableFromInline
struct NoInterpolationValidator: AsyncValidatable {

  @usableFromInline
  let request: ServerRoute.Api.Route.Interpolation.SingleInterpolation

  @usableFromInline
  let noInterpolation:
    ServerRoute.Api.Route.Interpolation.SingleInterpolation.Route.Cooling.NoInterpolation

  @usableFromInline
  init(
    request: ServerRoute.Api.Route.Interpolation.SingleInterpolation,
    noInterpolation: ServerRoute.Api.Route.Interpolation.SingleInterpolation.Route.Cooling
      .NoInterpolation
  ) {
    self.request = request
    self.noInterpolation = noInterpolation
  }

  @usableFromInline
  var body: some AsyncValidation<Self> {
    AsyncValidator.accumulating {
      AsyncValidator.validate(
        \.noInterpolation.capacity,
        with: CoolingCapacityEnvelopeValidation(errorLabel: ErrorLabel.capacity)
      )
      .errorLabel("Capacity")

      AsyncValidator.validate(\.request.houseLoad, with: HouseLoadValidator(style: .cooling))
        .errorLabel("House Load")

      AsyncValidator.validate(
        \.noInterpolation.manufacturerAdjustments,
        with: AdjustmentMultiplierValidation(
          style: .cooling, label: ErrorLabel.manufacturerAdjustments
        )
        .optional()
      )
      .errorLabel("Manufacturer Adjustments")

      AsyncValidator.accumulating {
        AsyncValidator.equals(
          \.noInterpolation.capacity.outdoorTemperature,
          \.request.designInfo.summer.outdoorTemperature
        )
        .mapError(
          nested: ErrorLabel.parenthesize(ErrorLabel.capacity, ErrorLabel.designInfoSummer),
          ErrorLabel.outdoorTemperature,
          summary:
            "Capacity outdoor temperature should equal the summer design outdoor temperature."
        )
        AsyncValidator.equals(
          \.noInterpolation.capacity.indoorTemperature,
          \.request.designInfo.summer.indoorTemperature
        )
        .mapError(
          nested: ErrorLabel.parenthesize(ErrorLabel.capacity, ErrorLabel.designInfoSummer),
          ErrorLabel.indoorTemperature,
          summary:
            "Capacity indoor temperature should equal the summer design indoor temperature."
        )
      }
      .errorLabel("General")
    }
    .errorLabel("No Interpolation Request Errors")
  }
}
