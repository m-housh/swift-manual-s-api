import Foundation
import Models
import Validations

extension ServerRoute.Api.Route.InterpolationRequest.Heating {

  func respond() async throws -> InterpolationResponse.Heating {
    let result: InterpolationResponse.Heating.Result
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

extension ServerRoute.Api.Route.InterpolationRequest.Heating {

  fileprivate func interpolate(furnace: FurnaceRequest) async throws
    -> InterpolationResponse.Heating.Result
  {
    //    try await furnace.validate()

    let output = Double(furnace.input) * (furnace.afue / 100)
    var finalCapacity = output
    if case let .heating(derating) = furnace.altitudeDeratings {
      finalCapacity *= derating
    }

    let percentOfLoad = finalCapacity / Double(furnace.houseLoad.heating)

    return .furnace(
      .init(
        outputCapacity: Int(output),
        finalCapacity: Int(finalCapacity),
        percentOfLoad: .normalizePercentage(percentOfLoad)
      ))
  }

  fileprivate func interpolate(electric: ElectricRequest) async throws
    -> InterpolationResponse.Heating.Result
  {
    //    try await electric.validate()
    let requredKWRequest = ServerRoute.Api.Route.RequiredKWRequest(
      capacityAtDesign: Double(electric.heatPumpCapacity ?? 0),
      heatLoss: Double(electric.houseLoad.heating)
    )
    let requiredKW = try await requredKWRequest.respond().requiredKW

    let percentOfLoad = electric.inputKW / requiredKW

    return .electric(
      .init(
        requiredKW: requiredKW,
        percentOfLoad: .normalizePercentage(percentOfLoad)
      ))
  }

  fileprivate func interpolate(heatPump: HeatPumpRequest) async throws
    -> InterpolationResponse.Heating.Result
  {
    //    try await heatPump.capacity.validate()

    var finalCapacity = heatPump.capacity
    if case let .airToAir(total: _, sensible: _, heating: derating) = heatPump.altitudeDeratings {
      finalCapacity = await heatPump.capacity.derate(derating)
    }
    let balancePointRequest = ServerRoute.Api.Route.BalancePointRequest.thermal(
      .init(
        designTemperature: Double(heatPump.designInfo.winter.outdoorTemperature),
        heatLoss: Double(heatPump.houseLoad.heating),
        capacity: finalCapacity
      ))
    let balancePoint = try await balancePointRequest.respond().balancePoint
    let capacityAtDesign = await finalCapacity.capacity(
      at: heatPump.designInfo.winter.outdoorTemperature)
    let requredKWRequest = ServerRoute.Api.Route.RequiredKWRequest(
      capacityAtDesign: capacityAtDesign,
      heatLoss: Double(heatPump.houseLoad.heating)
    )
    let requiredKW = try await requredKWRequest.respond().requiredKW

    return .heatPump(
      .init(
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

extension ServerRoute.Api.Route.InterpolationRequest.Heating.BoilerRequest {
  fileprivate var furnaceRequest: ServerRoute.Api.Route.InterpolationRequest.Heating.FurnaceRequest
  {
    .init(
      altitudeDeratings: self.altitudeDeratings,
      houseLoad: self.houseLoad,
      input: self.input,
      afue: self.afue
    )
  }
}

extension InterpolationResponse.Heating.Result {

  fileprivate func boilerResult() async throws -> Self {
    switch self {
    case let .furnace(furnace):
      return .boiler(
        .init(
          outputCapacity: furnace.outputCapacity,
          finalCapacity: furnace.finalCapacity,
          percentOfLoad: furnace.percentOfLoad
        ))
    default:
      throw ValidationError(summary: "Invalid conversion.")  // better error.
    }
  }
}
