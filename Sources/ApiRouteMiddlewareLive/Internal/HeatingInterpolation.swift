import Foundation
import Models
import Validations

extension ServerRoute.Api.Route.Interpolation.Heating {

  func respond() async throws -> InterpolationResponse {
    let result: InterpolationResult.Heating.Result
    switch self {
    case let .boiler(boiler):
      result = try await interpolate(furnace: boiler.furnaceRequest).boilerResult()
    case let .electric(electric):
      result = try await interpolate(electric: electric)
    case let .furnace(furnace):
      result = try await interpolate(furnace: furnace)
    case let .heatPump(heatPump):
      result = try await interpolate(heatPump: heatPump)
    }
    return .init(result: result)
  }

}

// MARK: - Interpolations
extension InterpolationResponse {

  init(result: InterpolationResult.Heating.Result) {
    self.init(
      failures: result.validateSizingLimits(),
      result: .heating(.init(result: result))
    )
  }
}

extension ServerRoute.Api.Route.Interpolation.Heating {

  fileprivate func interpolate(furnace: Furnace) async throws
    -> InterpolationResult.Heating.Result
  {

    let output = Double(furnace.input) * (furnace.afue / 100)
    var finalCapacity = output

    let altitudeDerating = try await ServerRoute.Api.Route.Derating(
      elevation: furnace.elevation,
      systemType: .furnaceOnly
    ).respond()

    if case let .heating(derating) = altitudeDerating {
      finalCapacity *= derating
    }

    let percentOfLoad = finalCapacity / Double(furnace.houseLoad.heating)

    return .furnace(
      .init(
        altitudeDeratings: altitudeDerating,
        outputCapacity: Int(output),
        finalCapacity: Int(finalCapacity),
        percentOfLoad: .normalizePercentage(percentOfLoad)
      ))
  }

  fileprivate func interpolate(electric: Electric) async throws
    -> InterpolationResult.Heating.Result
  {
    //    try await electric.validate()
    let requredKWRequest = ServerRoute.Api.Route.RequiredKW(
      capacityAtDesign: Double(electric.heatPumpCapacity ?? 0),
      heatLoss: Double(electric.houseLoad.heating)
    )
    let requiredKW = try await requredKWRequest.respond().requiredKW

    let percentOfLoad = electric.inputKW / requiredKW
    //    let sizingLimits =

    return .electric(
      .init(
        requiredKW: requiredKW,
        percentOfLoad: .normalizePercentage(percentOfLoad)
      ))
  }

  // TODO: FIX DERATINGS.
  fileprivate func interpolate(heatPump: HeatPump) async throws
    -> InterpolationResult.Heating.Result
  {

    var finalCapacity = heatPump.capacity

    let altitudeDeratings = try await ServerRoute.Api.Route.Derating(
      elevation: heatPump.designInfo.elevation,
      systemType: heatPump.systemType
    ).respond()

    if case let .airToAir(total: _, sensible: _, heating: derating) = altitudeDeratings {
      finalCapacity = await heatPump.capacity.derate(derating)
    }
    let balancePointRequest = ServerRoute.Api.Route.BalancePoint.thermal(
      .init(
        designTemperature: Double(heatPump.designInfo.winter.outdoorTemperature),
        heatLoss: Double(heatPump.houseLoad.heating),
        capacity: finalCapacity
      ))
    let balancePoint = try await balancePointRequest.respond().balancePoint
    let capacityAtDesign = await finalCapacity.capacity(
      at: heatPump.designInfo.winter.outdoorTemperature)
    let requredKWRequest = ServerRoute.Api.Route.RequiredKW(
      capacityAtDesign: capacityAtDesign,
      heatLoss: Double(heatPump.houseLoad.heating)
    )
    let requiredKW = try await requredKWRequest.respond().requiredKW

    return .heatPump(
      .init(
        altitudeDeratings: altitudeDeratings,
        finalCapacity: finalCapacity,
        capacityAtDesign: Int(capacityAtDesign),
        balancePointTemperature: balancePoint,
        requiredKW: requiredKW
      ))
  }
}

// MARK: - Helpers

extension HeatPumpCapacity {
  fileprivate func derate(_ value: Double) async -> Self {
    let at17 = Double(at17) * value
    let at47 = Double(at47) * value
    return .init(at47: Int(at47), at17: Int(at17))
  }

  fileprivate func capacity(at outdoorTemperature: Int) async -> Double {
    let outdoorTemperature = Double(outdoorTemperature)
    let x = Double((at47 - at17) / 30)
    let y = 17 - outdoorTemperature
    let z = x * y
    return round((Double(at17) - z) * 100.0) / 100.0
  }
}

extension ServerRoute.Api.Route.Interpolation.Heating.Boiler {
  fileprivate var furnaceRequest: ServerRoute.Api.Route.Interpolation.Heating.Furnace {
    .init(
      elevation: self.elevation,
      houseLoad: self.houseLoad,
      input: self.input,
      afue: self.afue
    )
  }
}

extension InterpolationResult.Heating.Result {

  fileprivate func boilerResult() async throws -> Self {
    switch self {
    case let .furnace(furnace):
      return .boiler(
        .init(
          altitudeDeratings: furnace.altitudeDeratings,
          outputCapacity: furnace.outputCapacity,
          finalCapacity: furnace.finalCapacity,
          percentOfLoad: furnace.percentOfLoad
        ))
    default:
      throw ValidationError(summary: "Invalid conversion.")  // better error.
    }
  }
}

extension InterpolationResult.Heating.Result {
  var sizingLimits: SizingLimits? {
    switch self {
    case let .boiler(boiler):
      return boiler.sizingLimits
    case let .electric(electric):
      return electric.sizingLimits
    case let .furnace(furnace):
      return furnace.sizingLimits
    case .heatPump(_):
      return nil
    }
  }

  func validateSizingLimits() -> [String]? {
    sizingLimits?.validate(result: self)
  }
}

extension SizingLimits {

  private func validateBoiler(_ boiler: InterpolationResult.Heating.Result.Boiler) -> [String]? {
    guard case let .boiler(oversizing) = self.oversizing,
      case let .boiler(undersizing) = self.undersizing
    else {
      return ["Invalid sizing limits \(self)."]
    }
    var failures = [String]()
    if boiler.percentOfLoad > Double(oversizing) {
      failures.append("Oversizing failure.")
    }
    if boiler.percentOfLoad < Double(undersizing) {
      failures.append("Undersizing failure.")
    }

    return failures.isEmpty ? nil : failures
  }

  private func validateFurnace(_ furnace: InterpolationResult.Heating.Result.Furnace) -> [String]? {
    guard case let .furnace(oversizing) = self.oversizing,
      case let .furnace(undersizing) = self.undersizing
    else {
      return ["Invalid sizing limits \(self)."]
    }
    var failures = [String]()
    if furnace.percentOfLoad > Double(oversizing) {
      failures.append("Oversizing failure.")
    }
    if furnace.percentOfLoad < Double(undersizing) {
      failures.append("Undersizing failure.")
    }

    return failures.isEmpty ? nil : failures
  }

  private func validateElectric(_ furnace: InterpolationResult.Heating.Result.Electric)
    -> [String]?
  {
    guard case let .electric(oversizing) = self.oversizing,
      case let .electric(undersizing) = self.undersizing
    else {
      return ["Invalid sizing limits \(self)."]
    }
    var failures = [String]()
    if furnace.percentOfLoad > Double(oversizing) {
      failures.append("Oversizing failure.")
    }
    if furnace.percentOfLoad < Double(undersizing) {
      failures.append("Undersizing failure.")
    }

    return failures.isEmpty ? nil : failures
  }

  fileprivate func validate(result: InterpolationResult.Heating.Result) -> [String]? {
    switch result {
    case let .boiler(boiler):
      return validateBoiler(boiler)
    case let .electric(electric):
      return validateElectric(electric)
    case let .furnace(furnace):
      return validateFurnace(furnace)
    case .heatPump(_):
      return nil
    }
  }
}
