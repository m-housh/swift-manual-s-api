import Models
import Validations

extension ServerRoute.Api.Route.BalancePoint.Thermal: AsyncValidatable {

  @inlinable
  public var body: some AsyncValidation<Self> {
    AsyncValidator.accumulating {
      AsyncValidator.greaterThan(\.heatLoss, 0)
        .mapError(
          label: ErrorLabel.heatLoss,
          summary: "Heat loss should be greater than 0."
        )

      AsyncValidator.validate(
        \.capacity,
        with: HeatPumpCapacityValidation(label: ErrorLabel.capacity)
      )
    }
    .errorLabel("Thermal Balance Point Request Errors")
  }
}

extension ServerRoute.Api.Route.BalancePoint: AsyncValidatable {

  @inlinable
  public func validate(_ value: ServerRoute.Api.Route.BalancePoint) async throws {
    switch value {
    case let .thermal(thermal):
      try await thermal.validate()
    }
  }
}
