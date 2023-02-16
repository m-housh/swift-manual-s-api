import Models
import Validations

@usableFromInline
enum OneWayRequestValidation: AsyncValidatable {

  @usableFromInline
  typealias OneWayRequest = ServerRoute.Api.Route.Interpolation.Cooling.OneWay

  case indoor(OneWayRequest)
  case outdoor(OneWayRequest)

  @usableFromInline
  func aboveDesign(
    @AsyncValidationBuilder<OneWayRequest> build: () -> some AsyncValidation<OneWayRequest>
  )
    -> some AsyncValidation<OneWayRequest>
  {

    AsyncValidator.accumulating {
      AsyncValidator.validate(
        \OneWayRequest.aboveDesign,
        with: CoolingCapacityEnvelopeValidation(errorLabel: ErrorLabel.aboveDesign)
      )

      build()
    }
  }

  @usableFromInline
  func belowDesign(
    @AsyncValidationBuilder<OneWayRequest> build: () -> some AsyncValidation<OneWayRequest>
  )
    -> some AsyncValidation<OneWayRequest>
  {

    AsyncValidator.accumulating {
      AsyncValidator.validate(
        \OneWayRequest.belowDesign,
        with: CoolingCapacityEnvelopeValidation(errorLabel: ErrorLabel.belowDesign)
      )

      build()
    }
  }

  @usableFromInline
  var outdoorAsyncValidator: any AsyncValidation<OneWayRequest> {
    AsyncValidator<OneWayRequest>.accumulating {

      aboveDesign {
        AsyncValidator.equals(\OneWayRequest.aboveDesign.indoorWetBulb, 63)
          .mapError(
            nested: ErrorLabel.aboveDesign, ErrorLabel.indoorWetBulb,
            summary: "Above design indoor wet-bulb should equal 63°."
          )

      }
      .errorLabel(label: "Above Design")

      belowDesign {
        AsyncValidator.equals(\OneWayRequest.belowDesign.indoorWetBulb, 63)
          .mapError(
            nested: ErrorLabel.belowDesign, ErrorLabel.indoorWetBulb,
            summary: "Below design indoor wet-bulb should equal 63°."
          )
      }
      .errorLabel("Below Design")

      AsyncValidator.validate(\.houseLoad, with: HouseLoadValidator(style: .cooling))
        .errorLabel("House Load")

      AsyncValidator.validate(
        \.manufacturerAdjustments,
        with: AdjustmentMultiplierValidation(
          style: .cooling, label: ErrorLabel.manufacturerAdjustments
        ).optional()
      )
      .errorLabel("Manufacturer Adjustments")

      AsyncValidator.accumulating {
        AsyncValidator.lessThan(
          \OneWayRequest.belowDesign.outdoorTemperature,
          \OneWayRequest.designInfo.summer.outdoorTemperature
        )
        .mapError(
          nested: ErrorLabel.parenthesize(ErrorLabel.belowDesign, ErrorLabel.designInfoSummer),
          ErrorLabel.outdoorTemperature,
          summary:
            "Below design outdoor temperature should be less than the summer design outdoor temperature."
        )

        AsyncValidator.greaterThan(
          \OneWayRequest.aboveDesign.outdoorTemperature,
          \OneWayRequest.designInfo.summer.outdoorTemperature
        )
        .mapError(
          nested: ErrorLabel.parenthesize(ErrorLabel.aboveDesign, ErrorLabel.designInfoSummer),
          ErrorLabel.outdoorTemperature,
          summary:
            "Above design outdoor temperature should be greater than the summer design outdoor temperature."
        )
      }
      .errorLabel("General")
    }
    .errorLabel("One Way Outdoor Request Errors")
  }

  @usableFromInline
  var indoorAsyncValidator: any AsyncValidation<OneWayRequest> {
    AsyncValidator.accumulating {

      aboveDesign {
        AsyncValidator.greaterThan(\.aboveDesign.indoorWetBulb, 63)
          .mapError(
            nested: .aboveDesign, .indoorWetBulb,
            summary: "Above design indoor wet-bulb should be greater than 63°."
          )
      }
      .errorLabel("Above Design")

      belowDesign {
        AsyncValidator.lessThan(\.belowDesign.indoorWetBulb, 63)
          .mapError(
            nested: .belowDesign, .indoorWetBulb,
            summary: "Below design indoor wet-bulb should be less than 63°."
          )
      }
      .errorLabel("Below Design")

      AsyncValidator.validate(\.houseLoad, with: HouseLoadValidator(style: .cooling))
        .errorLabel("House Load")

      AsyncValidator.validate(
        \.manufacturerAdjustments,
        with: AdjustmentMultiplierValidation(
          style: .cooling, label: ErrorLabel.manufacturerAdjustments
        ).optional()
      )
      .errorLabel("Manufacturer Adjustments")

      AsyncValidator.accumulating {
        AsyncValidator.equals(\.aboveDesign.indoorTemperature, \.belowDesign.indoorTemperature)
          .mapError(
            nested: ErrorLabel.parenthesize(ErrorLabel.aboveDesign, ErrorLabel.belowDesign),
            ErrorLabel.indoorTemperature,
            summary:
              "Above design indoor temperature should equal the below design indoor temperature."
          )

        AsyncValidator.equals(\OneWayRequest.aboveDesign.cfm, \OneWayRequest.belowDesign.cfm)
          .mapError(
            nested: ErrorLabel.parenthesize(ErrorLabel.aboveDesign, ErrorLabel.belowDesign),
            ErrorLabel.cfm,
            summary: "Above design cfm should equal below design cfm."
          )
      }
      .errorLabel("General")
    }
    .errorLabel("One Way Indoor Request Errors")
  }

  @usableFromInline
  func validate(_ value: Self) async throws {
    switch value {
    case let .indoor(indoorRequest):
      return try await indoorAsyncValidator.validate(indoorRequest)
    case let .outdoor(outdoorRequest):
      return try await outdoorAsyncValidator.validate(outdoorRequest)
    }
  }
}
