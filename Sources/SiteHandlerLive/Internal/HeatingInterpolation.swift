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

// MARK: - Validations
extension ServerRoute.Api.Route.InterpolationRequest.Heating.FurnaceRequest: AsyncValidatable {
  
  public var body: some AsyncValidator<Self> {
    AsyncValidation {
      Validate(\.afue) {
        GreaterThan(0)
        Not(GreaterThan(100))
      }
      GreaterThan(\.input, 0)
    }
  }
}

extension ServerRoute.Api.Route.InterpolationRequest.Heating.ElectricRequest: AsyncValidatable {
  
  public var body: some AsyncValidator<Self> {
    AsyncValidation {
      GreaterThan(\.inputKW, 0)
      GreaterThan(\.houseLoad.heating, 0)
    }
  }
}

// MARK: - Interpolations

fileprivate extension ServerRoute.Api.Route.InterpolationRequest.Heating {
  
  func interpolate(furnace: FurnaceRequest) async throws -> InterpolationResponse.Heating.Result {
    try await furnace.validate()
    
    let output = Double(furnace.input) * (furnace.afue / 100)
    var finalCapacity = output
    if case let .heating(derating) = furnace.altitudeDeratings {
      finalCapacity *= derating
    }
    
    let percentOfLoad =  finalCapacity / Double(furnace.houseLoad.heating)
    
    return .furnace(.init(
      outputCapacity: Int(output),
      finalCapacity: Int(finalCapacity),
      percentOfLoad: .normalizePercentage(percentOfLoad)
    ))
  }
  
  func interpolate(electric: ElectricRequest) async throws -> InterpolationResponse.Heating.Result {
    try await electric.validate()
    let requredKWRequest = ServerRoute.Api.Route.RequiredKW(
      capacityAtDesign: Double(electric.heatPumpCapacity ?? 0),
      heatLoss: Double(electric.houseLoad.heating)
    )
    let requiredKW = try await requredKWRequest.respond().requiredKW
   
    let percentOfLoad = electric.inputKW / requiredKW
    
    return .electric(.init(
      requiredKW: requiredKW,
      percentOfLoad: .normalizePercentage(percentOfLoad)
    ))
  }
  
  func interpolate(heatPump: HeatPumpRequest) async throws -> InterpolationResponse.Heating.Result {
    try await heatPump.capacity.validate()
    
    var finalCapacity = heatPump.capacity
    if case let .airToAir(total: _, sensible: _, heating: derating) = heatPump.altitudeDeratings {
      finalCapacity = await heatPump.capacity.derate(derating)
    }
    let balancePointRequest = ServerRoute.Api.Route.BalancePointRequest.thermal(.init(
      designTemperature: Double(heatPump.designInfo.winter.outdoorTemperature),
      heatLoss: Double(heatPump.houseLoad.heating),
      capacity: finalCapacity
    ))
    let balancePoint = try await balancePointRequest.respond().balancePoint
    let capacityAtDesign = await finalCapacity.capacity(at: heatPump.designInfo.winter.outdoorTemperature)
    let requredKWRequest = ServerRoute.Api.Route.RequiredKW(
      capacityAtDesign: capacityAtDesign,
      heatLoss: Double(heatPump.houseLoad.heating)
    )
    let requiredKW = try await requredKWRequest.respond().requiredKW
   
    return .heatPump(.init(
      finalCapacity: finalCapacity,
      capacityAtDesign: Int(capacityAtDesign),
      balancePointTemperature: balancePoint,
      requiredKW: requiredKW
    ))
    
  }
}

// MARK: - Helpers

fileprivate extension HeatPumpCapacity {
  func derate(_ value: Double) async -> Self {
    let at17 = Double(at17) * value
    let at47 = Double(at47) * value
    return .init(at47: Int(at47), at17: Int(at17))
  }
  
  func capacity(at outdoorTemperature: Int) async -> Double {
    let outdoorTemperature = Double(outdoorTemperature)
    let x = Double((at47 - at17) / 30)
    let y = 17 - outdoorTemperature
    let z = x * y
    return round((Double(at17) - z) * 100.0) / 100.0
  }
}

fileprivate extension ServerRoute.Api.Route.InterpolationRequest.Heating.BoilerRequest {
  var furnaceRequest: ServerRoute.Api.Route.InterpolationRequest.Heating.FurnaceRequest {
    .init(
      altitudeDeratings: self.altitudeDeratings,
      houseLoad: self.houseLoad,
      input: self.input,
      afue: self.afue
    )
  }
}

fileprivate extension InterpolationResponse.Heating.Result {
  
  func boilerResult() async throws -> Self {
    switch self {
    case let .furnace(furnace):
      return .boiler(.init(
        outputCapacity: furnace.outputCapacity,
        finalCapacity: furnace.finalCapacity,
        percentOfLoad: furnace.percentOfLoad
      ))
    default:
      throw ValidationError("Invalid conversion.") // better error.
    }
  }
}
