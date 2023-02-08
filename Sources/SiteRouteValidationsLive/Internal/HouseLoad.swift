import Models
import Validations

@usableFromInline
struct HouseLoadValidator: AsyncValidation {

  @usableFromInline
  typealias Value = HouseLoad

  @usableFromInline
  let style: Style

  let errorLabel: any CustomStringConvertible

  @usableFromInline
  init(style: Style, label: any CustomStringConvertible = ErrorLabel.houseLoad) {
    self.style = style
    self.errorLabel = label
  }

  @usableFromInline
  var coolingValidator: some AsyncValidation<HouseLoad.CoolingLoad> {
    AsyncValidator.accumulating {
      AsyncValidator.validate(\.total, with: .greaterThan(0))
        .mapError(
          nested: errorLabel, ErrorLabel.total,
          summary: "Total cooling load should be greater than 0."
        )

      AsyncValidator.validate(\.total, with: .greaterThan(0))
        .mapError(
          nested: errorLabel, ErrorLabel.sensible,
          summary: "Sensible cooling load should be greater than 0."
        )
    }
    .map {
      AsyncValidator.greaterThanOrEquals(\.total, \.sensible)
        .mapError(
          nested: errorLabel,
          summary: "Total load should be greater than or equal to the sensible load."
        )
    }
  }

  @usableFromInline
  var heatingValidator: some AsyncValidation<HouseLoad> {
    AsyncValidator.validate(\.heating, with: .greaterThan(0))
      .mapError(
        nested: errorLabel, ErrorLabel.heating,
        summary: "Heating load should be greater than 0."
      )
  }

  @usableFromInline
  func validate(_ value: HouseLoad) async throws {

    switch style {
    case .heating:
      try await heatingValidator.validate(value)
    case .cooling:
      try await coolingValidator.validate(value.cooling)
    }

  }

  @usableFromInline
  enum Style {
    case heating
    case cooling
  }
}
