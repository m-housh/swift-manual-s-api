import Foundation
import ManualSClient
import Models

extension ManualSClient.HeatingInterpolation {
  
  func run() async throws -> ManualSClient.HeatingInterpolation.Result {
    switch self {
    case let .boiler(boiler):
      return try await interpolate(furnace: boiler.furnaceRequest).boilerResult()
    case .electric(_):
      throw ValidationError("fix me.")
    case let .furnace(furnace):
      return try await interpolate(furnace: furnace)
    case .heatPump(_):
      throw ValidationError("fix me.")
    }
  }
  
  fileprivate func validate(input: Int) async throws {
    guard input > 0 else {
      throw ValidationError("Input should be greater than zero.")
    }
  }
  
  fileprivate func validate(afue: Double) async throws {
    guard afue > 0 else {
      throw ValidationError("AFUE should be greater than zero.")
    }
    guard afue < 100 else {
      throw ValidationError("AFUE should be less than 100.")
    }
  }
  
  fileprivate func interpolate(furnace: FurnaceRequest) async throws -> Self.Result {
    try await validate(input: furnace.input)
    try await validate(afue: furnace.afue)
    
    let output = Double(furnace.input) * (furnace.afue / 100)
    var finalCapacity = output
    if let deratings = furnace.altitudeDeratings,
        case let .heating(derating) = deratings
    {
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
//    case .boiler:
//      return self
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
