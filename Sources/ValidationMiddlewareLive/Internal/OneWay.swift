import Models
import Validations

@usableFromInline
struct OneWayIndoorValidation: AsyncValidatable {

  @usableFromInline
  let request: ServerRoute.Api.Route.Interpolation

  @usableFromInline
  let oneWayIndoor: ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay

  @usableFromInline
  init(
    request: ServerRoute.Api.Route.Interpolation,
    oneWayIndoor: ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay
  ) {
    self.request = request
    self.oneWayIndoor = oneWayIndoor
  }

  @usableFromInline
  var body: some AsyncValidation<Self> {
    AsyncValidator.accumulating {

      //      AsyncValidator.accumulating {
      //        AsyncValidator.validate(
      //          \.oneWayIndoor.aboveDesign,
      //           with: CoolingCapacityEnvelopeValidation(errorLabel: ErrorLabel.aboveDesign)
      //        )
      //
      //        AsyncValidator.greaterThan(\.oneWayIndoor.aboveDesign.indoorWetBulb, 63)
      //          .mapError(
      //            nested: .aboveDesign, .indoorWetBulb,
      //            summary: "Above design indoor wet-bulb should be greater than 63°."
      //          )
      //      }
      //      .errorLabel("Above Design")
      //
      //      AsyncValidator.accumulating {
      //        AsyncValidator.validate(
      //          \.oneWayIndoor.belowDesign,
      //           with: CoolingCapacityEnvelopeValidation(errorLabel: ErrorLabel.belowDesign)
      //        )
      //        AsyncValidator.lessThan(\.oneWayIndoor.belowDesign.indoorWetBulb, 63)
      //          .mapError(
      //            nested: .belowDesign, .indoorWetBulb,
      //            summary: "Below design indoor wet-bulb should be less than 63°."
      //          )
      //      }
      //      .errorLabel("Below Design")

      AsyncValidator.validate(\.request.houseLoad, with: HouseLoadValidator(style: .cooling))
        .errorLabel("House Load")

      AsyncValidator.validate(
        \.oneWayIndoor.manufacturerAdjustments,
        with: AdjustmentMultiplierValidation(
          style: .cooling, label: ErrorLabel.manufacturerAdjustments
        ).optional()
      )
      .errorLabel("Manufacturer Adjustments")

      AsyncValidator.accumulating {
        AsyncValidator.equals(
          \.oneWayIndoor.aboveDesign.indoorTemperature, \.oneWayIndoor.belowDesign.indoorTemperature
        )
        .mapError(
          nested: ErrorLabel.parenthesize(ErrorLabel.aboveDesign, ErrorLabel.belowDesign),
          ErrorLabel.indoorTemperature,
          summary:
            "Above design indoor temperature should equal the below design indoor temperature."
        )

        AsyncValidator.equals(\.oneWayIndoor.aboveDesign.cfm, \.oneWayIndoor.belowDesign.cfm)
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
}

@usableFromInline
struct OneWayOutdoorValidation: AsyncValidatable {

  @usableFromInline
  let request: ServerRoute.Api.Route.Interpolation

  @usableFromInline
  let oneWayOutdoor: ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay

  @usableFromInline
  init(
    request: ServerRoute.Api.Route.Interpolation,
    oneWayOutdoor: ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay
  ) {
    self.request = request
    self.oneWayOutdoor = oneWayOutdoor
  }

  @usableFromInline
  var body: some AsyncValidation<Self> {
    AsyncValidator.accumulating {

      //      AsyncValidator.accumulating {
      //        AsyncValidator.validate(
      //          \.oneWayOutdoor.aboveDesign,
      //           with: CoolingCapacityEnvelopeValidation(errorLabel: ErrorLabel.aboveDesign)
      //        )
      //        AsyncValidator.equals(\.oneWayOutdoor.aboveDesign.indoorWetBulb, 63)
      //          .mapError(
      //            nested: ErrorLabel.aboveDesign, ErrorLabel.indoorWetBulb,
      //            summary: "Above design indoor wet-bulb should equal 63°."
      //          )
      //      }
      //      .errorLabel("Above Design")
      //
      //      AsyncValidator.accumulating {
      //        AsyncValidator.validate(
      //          \.oneWayOutdoor.belowDesign,
      //           with: CoolingCapacityEnvelopeValidation(errorLabel: ErrorLabel.belowDesign)
      //        )
      //        AsyncValidator.equals(\.oneWayOutdoor.aboveDesign.indoorWetBulb, 63)
      //          .mapError(
      //            nested: ErrorLabel.aboveDesign, ErrorLabel.indoorWetBulb,
      //            summary: "Above design indoor wet-bulb should equal 63°."
      //          )
      //      }
      //      .errorLabel("Below Design")

      AsyncValidator.validate(\.request.houseLoad, with: HouseLoadValidator(style: .cooling))
        .errorLabel("House Load")

      AsyncValidator.validate(
        \.oneWayOutdoor.manufacturerAdjustments,
        with: AdjustmentMultiplierValidation(
          style: .cooling, label: ErrorLabel.manufacturerAdjustments
        ).optional()
      )
      .errorLabel("Manufacturer Adjustments")

      AsyncValidator.accumulating {
        AsyncValidator.lessThan(
          \.oneWayOutdoor.belowDesign.outdoorTemperature,
          \.request.designInfo.summer.outdoorTemperature
        )
        .mapError(
          nested: ErrorLabel.parenthesize(ErrorLabel.belowDesign, ErrorLabel.designInfoSummer),
          ErrorLabel.outdoorTemperature,
          summary:
            "Below design outdoor temperature should be less than the summer design outdoor temperature."
        )

        AsyncValidator.greaterThan(
          \.oneWayOutdoor.aboveDesign.outdoorTemperature,
          \.request.designInfo.summer.outdoorTemperature
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
}

//@usableFromInline
//enum OneWayRequestValidation: AsyncValidatable {
//
//  @usableFromInline
//  typealias OneWayRequest = ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay
//
//  case indoor(ServerRoute.Api.Route.Interpolation, OneWayRequest)
//  case outdoor(ServerRoute.Api.Route.Interpolation, OneWayRequest)
//
//  @usableFromInline
//  func aboveDesign(
//    @AsyncValidationBuilder<(ServerRoute.Api.Route.Interpolation, OneWayRequest)> build: () -> some AsyncValidation<(ServerRoute.Api.Route.Interpolation, OneWayRequest)>
//  )
//    -> some AsyncValidation<(ServerRoute.Api.Route.Interpolation, OneWayRequest)>
//  {
//
//    AsyncValidator.accumulating {
//      AsyncValidator.validate(
//        \OneWayRequest.aboveDesign,
//        with: CoolingCapacityEnvelopeValidation(errorLabel: ErrorLabel.aboveDesign)
//      )
//
//      build()
//    }
//  }
//
//  @usableFromInline
//  func belowDesign(
//    @AsyncValidationBuilder<(ServerRoute.Api.Route.Interpolation, OneWayRequest)> build: () -> some AsyncValidation<(ServerRoute.Api.Route.Interpolation, OneWayRequest)>
//  )
//    -> some AsyncValidation<(ServerRoute.Api.Route.Interpolation, OneWayRequest)>
//  {
//
//    AsyncValidator.accumulating {
//      AsyncValidator.validate(
//        \OneWayRequest.belowDesign,
//        with: CoolingCapacityEnvelopeValidation(errorLabel: ErrorLabel.belowDesign)
//      )
//
//      build()
//    }
//  }
//
//  @usableFromInline
//  var outdoorAsyncValidator: any AsyncValidation<(ServerRoute.Api.Route.Interpolation, OneWayRequest)> {
//    AsyncValidator<(ServerRoute.Api.Route.Interpolation, OneWayRequest)>.accumulating {
//
//      aboveDesign {
//
//
//      }
//      .errorLabel(label: "Above Design")
//
//      belowDesign {
//
//      }
//      .errorLabel("Below Design")
//
//      // FIX.
////      AsyncValidator.validate(\.houseLoad, with: HouseLoadValidator(style: .cooling))
////        .errorLabel("House Load")
//
//
//
//       FIX.
//
//    }
//    .errorLabel("One Way Outdoor Request Errors")
//  }
//
//  @usableFromInline
//  var indoorAsyncValidator: any AsyncValidation<OneWayRequest> {
//  }
//
//  @usableFromInline
//  func validate(_ value: Self) async throws {
//    switch value {
//    case let .indoor(indoorRequest):
//      return try await indoorAsyncValidator.validate(indoorRequest)
//    case let .outdoor(outdoorRequest):
//      return try await outdoorAsyncValidator.validate(outdoorRequest)
//    }
//  }
//}
