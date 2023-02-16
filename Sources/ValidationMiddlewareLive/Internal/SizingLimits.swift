import Models
import Validations

extension ServerRoute.Api.Route.SizingLimit: AsyncValidatable {
  @inlinable
  public func validate(_ value: Models.ServerRoute.Api.Route.SizingLimit) async throws {
    if case let .airToAir(type: _, compressor: _, climate: climate) = value.systemType {
      guard case .coldWinterOrNoLatentLoad = climate else { return }
      guard let load = value.houseLoad else {
        throw ValidationError(summary: "House load is required for \(climate).")
      }
      try await SizingLimitValidator(load: load).validate()
    }
  }
}

@usableFromInline
struct SizingLimitValidator: AsyncValidatable {

  @usableFromInline
  let load: HouseLoad

  @usableFromInline
  init(load: HouseLoad) {
    self.load = load
  }

  @usableFromInline
  var body: some AsyncValidation<Self> {
    AsyncValidator.greaterThan(\.load.cooling.total, 0)
      .mapError(
        nested: ErrorLabel.load, ErrorLabel.cooling, ErrorLabel.total,
        summary: "Total cooling load should be greater than 0."
      )
      .errorLabel("Sizing Limit Request Errors")
  }
}
