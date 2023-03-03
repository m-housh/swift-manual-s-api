import Models
import Validations

@usableFromInline
struct HeatingValidation<I: AsyncValidatable>: AsyncValidatable {

  @usableFromInline
  let request: ServerRoute.Api.Route.Interpolation.SingleInterpolation

  @usableFromInline
  let interpolation: I

  @usableFromInline
  let errorLabel: String

  @usableFromInline
  init(
    request: ServerRoute.Api.Route.Interpolation.SingleInterpolation,
    interpolation: I,
    errorLabel: String
  ) {
    self.request = request
    self.interpolation = interpolation
    self.errorLabel = errorLabel
  }

  @usableFromInline
  var body: some AsyncValidation<Self> {
    AsyncValidator.accumulating {
      AsyncValidator.validate(
        \.request.houseLoad,
        with: HouseLoadValidator(style: .heating)
      )
      AsyncValidator.validate(\.interpolation)
    }
    .errorLabel(errorLabel)
  }
}

extension ServerRoute.Api.Route.Interpolation.SingleInterpolation.Route.Heating.Boiler:
  AsyncValidatable
{

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
    }
  }
}

extension ServerRoute.Api.Route.Interpolation.SingleInterpolation.Route.Heating.Furnace:
  AsyncValidatable
{

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
    }
  }
}

extension ServerRoute.Api.Route.Interpolation.SingleInterpolation.Route.Heating.Electric:
  AsyncValidatable
{

  @inlinable
  public var body: some AsyncValidation<Self> {
    AsyncValidator.accumulating {
      AsyncValidator.validate(\.inputKW, with: .greaterThan(0))
        .mapError(
          label: ErrorLabel.inputKW,
          summary: "Input KW should be greater than 0."
        )

      AsyncValidator.validate(
        \.heatPumpCapacity,
        with: Int.greaterThan(0).async().optional()
      )
      .mapError(
        label: ErrorLabel.heatPumpCapacity,
        summary: "Heat pump capacity should be greater than 0."
      )
    }
  }
}

extension ServerRoute.Api.Route.Interpolation.SingleInterpolation.Route.Heating.HeatPump:
  AsyncValidatable
{

  @inlinable
  public var body: some AsyncValidation<Self> {
    AsyncValidator.validate(
      \.capacity,
      with: HeatPumpCapacityValidation(label: ErrorLabel.capacity)
    )
  }
}
