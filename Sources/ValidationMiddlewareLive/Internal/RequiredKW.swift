import Models
import Validations

extension ServerRoute.Api.Route.RequiredKWRequest: AsyncValidatable {

  @inlinable
  public var body: some AsyncValidation<Self> {
    AsyncValidator.accumulating {
      AsyncValidator.greaterThan(\.heatLoss, 0)
        .mapError(
          label: ErrorLabel.heatLoss,
          summary: "Heat loss should be greater than 0."
        )

      AsyncValidator.validate(
        \.capacityAtDesign,
        with: Double.greaterThanOrEquals(0).async().optional()
      )
      .mapError(
        label: ErrorLabel.capacityAtDesign,
        summary: "Capacity at design should be greater than or equal to 0."
      )
    }
    .errorLabel("Required KW Request Errors")
  }
}
