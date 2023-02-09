import Models
import Validations

extension ServerRoute.Api.Route.InterpolationRequest.Cooling.NoInterpolationRequest:
  AsyncValidatable
{
  @inlinable
  public var body: some AsyncValidation<Self> {
    AsyncValidator.accumulating {
      AsyncValidator.validate(
        \.capacity,
        with: CoolingCapacityEnvelopeValidation(errorLabel: ErrorLabel.capacity)
      )
      .errorLabel("Capacity")

      AsyncValidator.validate(\.houseLoad, with: HouseLoadValidator(style: .cooling))
        .errorLabel("House Load")

      AsyncValidator.validate(
        \.manufacturerAdjustments,
        with: AdjustmentMultiplierValidation(
          style: .cooling, label: ErrorLabel.manufacturerAdjustments
        )
        .optional()
      )
      .errorLabel("Manufacturer Adjustments")

      AsyncValidator.accumulating {
        AsyncValidator.equals(\.capacity.outdoorTemperature, \.designInfo.summer.outdoorTemperature)
          .mapError(
            nested: ErrorLabel.parenthesize(ErrorLabel.capacity, ErrorLabel.designInfoSummer),
            ErrorLabel.outdoorTemperature,
            summary:
              "Capacity outdoor temperature should equal the summer design outdoor temperature."
          )
        AsyncValidator.equals(\.capacity.indoorTemperature, \.designInfo.summer.indoorTemperature)
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
