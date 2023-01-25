import Foundation
import ManualSClient
import Models

extension ManualSClient.HeatingInterpolation {
  
  func run() async throws -> ManualSClient.HeatingInterpolation.Result {
    switch self {
    case let .boiler(boiler):
      return try await interpolate(furnace: boiler.furnaceRequest).boilerResult()
    case let .electric(electric):
      return try await interpolate(electric: electric)
    case let .furnace(furnace):
      return try await interpolate(furnace: furnace)
    case let .heatPump(heatPump):
      return try await interpolate(heatPump: heatPump)
    }
  }
  
}

fileprivate extension ManualSClient.HeatingInterpolation {
  
  func validate(input: Int) async throws {
    guard input > 0 else {
      throw ValidationError("Input should be greater than zero.")
    }
  }
  
  func validate(input: Double) async throws {
    guard input > 0 else {
      throw ValidationError("Input should be greater than zero.")
    }
  }
  
  func validate(afue: Double) async throws {
    guard afue > 0 else {
      throw ValidationError("AFUE should be greater than zero.")
    }
    guard afue < 100 else {
      throw ValidationError("AFUE should be less than 100.")
    }
  }
  
  func validate(capacity: HeatPumpCapacity) async throws {
    guard capacity.at17 > 0 else {
      throw ValidationError("Capacity @17° should be greater than zero.")
    }
    guard capacity.at47 > 0 else {
      throw ValidationError("Capacity @47° should be greater than zero.")
    }
  }
  
  func interpolate(furnace: FurnaceRequest) async throws -> Self.Result {
    try await validate(input: furnace.input)
    try await validate(afue: furnace.afue)
    
    let output = Double(furnace.input) * (furnace.afue / 100)
    var finalCapacity = output
    if case let .heating(derating) = furnace.altitudeDeratings {
      finalCapacity *= derating
    }
    
    let percentOfLoad =  finalCapacity / Double(furnace.houseLoad.heating)
    
    return .furnace(.init(
      request: furnace,
      outputCapacity: Int(output),
      finalCapacity: Int(finalCapacity),
      percentOfLoad: .normalizePercentage(percentOfLoad)
    ))
  }
  
  func interpolate(electric: ElectricRequest) async throws -> Self.Result {
    try await validate(input: electric.inputKW)
    let requiredKW = try await ManualSClient.RequiredKWRequest(
      houseLoad: electric.houseLoad,
      capacityAtDesign: electric.heatPumpCapacity ?? 0
    ).run()
    
    let percentOfLoad = electric.inputKW / requiredKW
    
    return .electric(.init(
      request: electric,
      requiredKW: requiredKW,
      percentOfLoad: .normalizePercentage(percentOfLoad)
    ))
  }
  
  func interpolate(heatPump: HeatPumpRequest) async throws -> Self.Result {
    try await validate(capacity: heatPump.capacity)
    
    var finalCapacity = heatPump.capacity
    if case let .airToAir(total: _, sensible: _, heating: derating) = heatPump.altitudeDeratings {
      finalCapacity = await heatPump.capacity.derate(derating)
    }
    let balancePoint = await finalCapacity.balancePoint(
      outdoorTemperature: heatPump.designInfo.winter.outdoorTemperature,
      designLoad: heatPump.houseLoad.heating
    )
    let capacityAtDesign = Int(
      await finalCapacity.capacity(at: heatPump.designInfo.winter.outdoorTemperature)
    )
    let requiredKW = try await ManualSClient.RequiredKWRequest(
      houseLoad: heatPump.houseLoad,
      capacityAtDesign: capacityAtDesign
    ).run()
    
    return .heatPump(.init(
      request: heatPump,
      finalCapacity: finalCapacity,
      capacityAtDesign: capacityAtDesign,
      balancePointTemperature: balancePoint,
      requiredKW: requiredKW
    ))
    
  }
}

fileprivate extension HeatPumpCapacity {
  func derate(_ value: Double) async -> Self {
    let at17 = Double(at17) * value
    let at47 = Double(at47) * value
    return .init(at47: Int(at47), at17: Int(at17))
  }
  
  func balancePoint(outdoorTemperature: Int, designLoad: Int) async -> Double {
    let outdoorTemperature = Double(outdoorTemperature)
    let designLoad = Double(designLoad)
    let at17 = Double(at17)
    let at47 = Double(at47)
    let result = (30 * (((outdoorTemperature - 65) * at47) + (65 * designLoad))
                  - ((outdoorTemperature - 65) * (at47 - at17) * 47))
    / ((30 * designLoad) - ((outdoorTemperature - 65) * (at47 - at17)))
    
    return round(result * 10.0) / 10.0
  }
  
  func capacity(at outdoorTemperature: Int) async -> Double {
    let outdoorTemperature = Double(outdoorTemperature)
    let x = Double((at47 - at17) / 30)
    let y = 17 - outdoorTemperature
    let z = x * y
    return round((Double(at17) - z) * 100.0) / 100.0
  }
}

fileprivate extension ManualSClient.HeatingInterpolation.BoilerRequest {
  var furnaceRequest: ManualSClient.HeatingInterpolation.FurnaceRequest {
    .init(
      altitudeDeratings: self.altitudeDeratings,
      houseLoad: self.houseLoad,
      input: self.input,
      afue: self.afue
    )
  }
}

fileprivate extension ManualSClient.HeatingInterpolation.FurnaceRequest {
  var boilerRequest: ManualSClient.HeatingInterpolation.BoilerRequest {
    .init(altitudeDeratings: self.altitudeDeratings, houseLoad: self.houseLoad, input: self.input, afue: self.afue)
  }
}

fileprivate extension ManualSClient.HeatingInterpolation.Result {
  
  func boilerResult() async throws -> Self {
    switch self {
    case let .furnace(furnace):
      return .boiler(.init(
        request: furnace.request.boilerRequest,
        outputCapacity: furnace.outputCapacity,
        finalCapacity: furnace.finalCapacity,
        percentOfLoad: furnace.percentOfLoad
      ))
    default:
      throw ValidationError("Invalid conversion.") // better error.
    }
  }
}

extension Double {
  static func normalizePercentage(_ value: Double) -> Double {
    (value * 1_000.0).rounded() / 10.0
  }
}
