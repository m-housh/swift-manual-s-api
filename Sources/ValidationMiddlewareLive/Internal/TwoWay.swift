import Models
import Validations

// TODO: Create custom validation type for capacity envelopes, to hold onto a parent error label.
//extension ServerRoute.Api.Route.InterpolationRequest.Cooling.TwoWayRequest.CapacityEnvelope: AsyncValidatable {
@usableFromInline
struct TwoWayCapacityEnvelopeValidation: AsyncValidation {

  @usableFromInline
  typealias Value = ServerRoute.Api.Route.Interpolation.Single.Route.Cooling.TwoWay
    .CapacityEnvelope

  @usableFromInline
  let errorLabel: any CustomStringConvertible

  @usableFromInline
  init(errorLabel: any CustomStringConvertible) {
    self.errorLabel = errorLabel
  }

  @usableFromInline
  var body: some AsyncValidation<Value> {
    AsyncValidator.accumulating {
      AsyncValidatorOf<Value>.validate(
        \.aboveWetBulb,
        with: CoolingCapacityEnvelopeValidation(
          errorLabel: ErrorLabel.nest(errorLabel, ErrorLabel.above)
        )
      )

      AsyncValidator.validate(
        \.belowWetBulb,
        with: CoolingCapacityEnvelopeValidation(
          errorLabel: ErrorLabel.nest(errorLabel, ErrorLabel.below)
        )
      )

      AsyncValidator.equals(\.aboveWetBulb.cfm, \.belowWetBulb.cfm)
        .mapError(
          nested: errorLabel,
          ErrorLabel.parenthesize(ErrorLabel.above, ErrorLabel.below),
          ErrorLabel.cfm,
          summary: "Above cfm should equal below design cfm."
        )

      AsyncValidator.equals(\.aboveWetBulb.indoorTemperature, \.belowWetBulb.indoorTemperature)
        .mapError(
          nested: errorLabel,
          ErrorLabel.parenthesize(ErrorLabel.above, ErrorLabel.below),
          ErrorLabel.indoorTemperature,
          summary: "Above indoor temperature should equal below design indoor temperature."
        )

      AsyncValidator.greaterThan(\.aboveWetBulb.indoorWetBulb, \.belowWetBulb.indoorWetBulb)
        .mapError(
          nested: errorLabel,
          ErrorLabel.parenthesize(ErrorLabel.above, ErrorLabel.below),
          ErrorLabel.indoorWetBulb,
          summary: "Above indoor wet-bulb should be greater than below design indoor wet-bulb."
        )

      AsyncValidator.greaterThan(\.aboveWetBulb.indoorWetBulb, 63)
        .mapError(
          nested: errorLabel, ErrorLabel.above, ErrorLabel.indoorWetBulb,
          summary: "Above indoor wet-bulb should be greater than 63??."
        )

      AsyncValidator.lessThan(\.belowWetBulb.indoorWetBulb, 63)
        .mapError(
          nested: errorLabel, ErrorLabel.below, ErrorLabel.indoorWetBulb,
          summary: "Below indoor wet-bulb should be greater than 63."
        )
    }
  }
}

@usableFromInline
struct TwoWayValidation: AsyncValidatable {

  @usableFromInline
  let request: ServerRoute.Api.Route.Interpolation.Single

  @usableFromInline
  let twoWay: ServerRoute.Api.Route.Interpolation.Single.Route.Cooling.TwoWay

  @usableFromInline
  init(
    request: ServerRoute.Api.Route.Interpolation.Single,
    twoWay: ServerRoute.Api.Route.Interpolation.Single.Route.Cooling.TwoWay
  ) {
    self.request = request
    self.twoWay = twoWay
  }

  @usableFromInline
  var body: some AsyncValidation<Self> {
    AsyncValidator<Self>.accumulating {
      AsyncValidator.validate(
        \.twoWay.aboveDesign.rawValue,
        with: TwoWayCapacityEnvelopeValidation(errorLabel: ErrorLabel.aboveDesign)
      )
      .errorLabel("Above Design")

      AsyncValidator.validate(
        \.twoWay.belowDesign.rawValue,
        with: TwoWayCapacityEnvelopeValidation(errorLabel: ErrorLabel.belowDesign)
      )
      .errorLabel("Below Design")

      AsyncValidator.validate(\.request.houseLoad, with: HouseLoadValidator(style: .cooling))
        .errorLabel("House Load")

      AsyncValidator.validate(
        \.twoWay.manufacturerAdjustments,
        with: AdjustmentMultiplierValidation(
          style: .cooling, label: ErrorLabel.manufacturerAdjustments
        ).optional()
      )
      .errorLabel("Manufacturer Adjustments")

      AsyncValidatorOf<Value>.accumulating {
        AsyncValidator.lessThan(
          \.twoWay.belowDesign.belowWetBulb.outdoorTemperature,
          \.request.designInfo.summer.outdoorTemperature
        )
        .mapError(
          nested: ErrorLabel.parenthesize(ErrorLabel.belowDesignBelow, ErrorLabel.designInfoSummer),
          ErrorLabel.outdoorTemperature,
          summary:
            "Below design below outdoorTemperature should be less than the summer design outdoor temperature."
        )
        AsyncValidator.equals(
          \.twoWay.belowDesign.belowWetBulb.indoorTemperature,
          \.request.designInfo.summer.indoorTemperature
        )
        .mapError(
          nested: ErrorLabel.parenthesize(ErrorLabel.belowDesignBelow, ErrorLabel.designInfoSummer),
          ErrorLabel.indoorTemperature,
          summary:
            "Below design below indoorTemperature should be less than the summer design indoor temperature."
        )
        AsyncValidator.equals(
          \.twoWay.aboveDesign.belowWetBulb.indoorTemperature,
          \.request.designInfo.summer.indoorTemperature
        )
        .mapError(
          nested: ErrorLabel.parenthesize(ErrorLabel.aboveDesignBelow, ErrorLabel.designInfoSummer),
          ErrorLabel.indoorTemperature,
          summary:
            "Above design below indoor temperature should be less than the summer design indoor temperature."
        )
        AsyncValidator.equals(
          \.twoWay.aboveDesign.belowWetBulb.cfm, \.twoWay.belowDesign.belowWetBulb.cfm
        )
        .mapError(
          nested: ErrorLabel.parenthesize(
            ErrorLabel.aboveDesignBelow, ErrorLabel.belowDesignBelow),
          ErrorLabel.cfm,
          summary: "Above design below.cfm should equal the below design below.cfm."
        )
      }
      .errorLabel("General")

    }
    .errorLabel("Two Way Request Errors")

  }
}
