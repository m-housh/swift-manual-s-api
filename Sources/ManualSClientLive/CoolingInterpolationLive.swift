import ManualSClient
import Models

extension ManualSClient.CoolingInterpolation {
  
  func run() async throws -> Self.Result {
    switch self {
    case let .noInterpolation(noInterpolation):
      return try await interpolate(noInterpolation: noInterpolation)
    case .oneWayIndoor:
      throw ValidationError("Fix me.")
    case let .oneWayOutdoor(oneWayOutdoor):
      return try await interpolate(oneWayOutdoor: oneWayOutdoor)
    case .twoWay:
      throw ValidationError("Fix me.")
    }
  }
}

// MARK: - Validations
fileprivate extension ManualSClient.CoolingInterpolation.CoolingCapacityEnvelope {
  
  func validate() async throws {
    guard self.cfm >= 0 else {
      throw ValidationError("CFM should be greater than 0")
    }
    guard self.capacity.total >= 0 else {
      throw ValidationError("Total capacity should be greater than 0")
    }
    guard self.capacity.sensible >= 0 else {
      throw ValidationError("Sensible capacity should be greater than 0")
    }
    guard self.indoorTemperature >= 0 else {
      throw ValidationError("Indoor temperature should be greater than 0")
    }
  }
}

fileprivate extension ManualSClient.CoolingInterpolation.OneWayRequest {
  
  func validateOneWayOutdoor() async throws {
    guard aboveDesign.cfm == belowDesign.cfm else {
      throw ValidationError("Above design CFM and below design CFM")
    }
    guard aboveDesign.indoorWetBulb == 63 else {
      throw ValidationError("Above design wet-bulb should be 63°.")
    }
    guard belowDesign.indoorWetBulb == 63 else {
      throw ValidationError("Below design wet-bulb should be 63°.")
    }
    guard belowDesign.outdoorTemperature < designInfo.summer.outdoorTemperature else {
      throw ValidationError("Below design outdoor temperature should be less than the design condition outdoor temperature.")
    }
    guard aboveDesign.outdoorTemperature > designInfo.summer.outdoorTemperature else {
      throw ValidationError("Above design outdoor temperature should be grater than the design condition outdoor temperature.")
    }
    
    try await aboveDesign.validate()
    try await belowDesign.validate()
  }
}

fileprivate extension ManualSClient.CoolingInterpolation.NoInterpolationRequest {
  
  func validate() async throws {
    try await self.capacity.validate()
    
    guard self.capacity.outdoorTemperature == self.designInfo.summer.outdoorTemperature else {
      throw ValidationError("Outdoor design temperature should match manufacturers capacity outdoor temperature.")
    }
    guard self.capacity.indoorTemperature == self.designInfo.summer.indoorTemperature else {
      throw ValidationError("Indoor design temperature should match manufacturers capacity indoor temperature.")
    }
  }

}

fileprivate extension ManualSClient.CoolingInterpolation {
  
//  func excessLatent(interpolatedCapacity: CoolingCapacity, houseLoad: HouseLoad) async -> Int {
//    (interpolatedCapacity.latent - houseLoad.cooling.latent) / 2
//  }
  
  func interpolate(noInterpolation: NoInterpolationRequest) async throws -> Self.Result {
    try await noInterpolation.validate()
    let envelope = try await CoolingInterpolationEnvelope(
      interpolatedCapacity: noInterpolation.capacity.capacity,
      request: noInterpolation
    )
    return .init(request: .noInterpolation(noInterpolation), envelope: envelope)
  }
  
  func interpolate(oneWayOutdoor: OneWayRequest) async throws -> Self.Result {
    try await oneWayOutdoor.validateOneWayOutdoor()
    let inerpolatedCapacity = await oneWayOutdoor.interpolatedCapacity()
    let envelope = try await CoolingInterpolationEnvelope(
      interpolatedCapacity: inerpolatedCapacity,
      request: oneWayOutdoor
    )
    return .init(request: .oneWayOutdoor(oneWayOutdoor), envelope: envelope)
  }
  
}

fileprivate extension ManualSClient.CoolingInterpolation.Result {
  
  init(request: ManualSClient.CoolingInterpolation, envelope: CoolingInterpolationEnvelope) {
    self.init(
      request: request,
      interpolatedCapacity: envelope.interpolatedCapacity,
      excessLatent: envelope.excessLatent,
      finalCapacityAtDesign: envelope.finalCapacity,
      altitudeDerating: envelope.altitudeDerating,
      capacityAsPercentOfLoad: envelope.capacityAsPercentOfLoad
    )
  }
}

fileprivate struct CoolingInterpolationEnvelope {
  let interpolatedCapacity: CoolingCapacity
  let excessLatent: Int
  let finalCapacity: CoolingCapacity
  let manufactererAdjustments: AdjustmentMultiplier?
  let altitudeDerating: AdjustmentMultiplier
  let capacityAsPercentOfLoad: CapacityAsPercentOfLoad
  
  init(
    interpolatedCapacity: CoolingCapacity,
    request: any CoolingInterpolationRequest
  ) async throws {
    
    let excessLatent = await request.excessLatent(interpolatedCapacity: interpolatedCapacity)
    
    var finalCapacity = interpolatedCapacity
    await finalCapacity.adjust(excessLatent: excessLatent)
    if let manufactererAdjustments = request.manufacturerAdjustments {
      await finalCapacity.apply(multiplier: manufactererAdjustments)
    }
    let altitudeDeratings = try await request.altitudeDerating()
    await finalCapacity.apply(multiplier: altitudeDeratings)
    
    self.interpolatedCapacity = interpolatedCapacity
    self.excessLatent = excessLatent
    self.altitudeDerating = altitudeDeratings
    self.manufactererAdjustments = request.manufacturerAdjustments
    self.finalCapacity = finalCapacity
    self.capacityAsPercentOfLoad = .init(houseLoad: request.houseLoad, finalCapacity: finalCapacity)
  }
}

fileprivate extension CoolingInterpolationRequest {
  
  func excessLatent(interpolatedCapacity: CoolingCapacity) async -> Int {
    (interpolatedCapacity.latent - houseLoad.cooling.latent) / 2
  }
  
  func altitudeDerating() async throws -> AdjustmentMultiplier {
    let request = ManualSClient.DeratingRequest.elevation(system: systemType, elevation: designInfo.elevation)
    return try await request.run()
  }
}

extension ManualSClient.CoolingInterpolation.OneWayRequest {

  func interpolatedCapacity() async -> CoolingCapacity {
    let total = await interpolateCapacity(
      outdoorDesignTemperature: designInfo.summer.outdoorTemperature,
      below: .total(belowDesign),
      above: .total(aboveDesign)
    )
    let sensible = await interpolateCapacity(
      outdoorDesignTemperature: designInfo.summer.outdoorTemperature,
      below: .sensible(belowDesign),
      above: .sensible(aboveDesign)
    )

    return .init(total: total, sensible: sensible)
  }
}

fileprivate struct OneWayEnvelope {
  let outdoorTemperature: Int
  let capacity: Int
  
  static func total(_ capacity: ManualSClient.CoolingInterpolation.CoolingCapacityEnvelope) -> Self {
    .init(outdoorTemperature: capacity.outdoorTemperature, capacity: capacity.capacity.total)
  }
  
  static func sensible(_ capacity: ManualSClient.CoolingInterpolation.CoolingCapacityEnvelope) -> Self {
    .init(outdoorTemperature: capacity.outdoorTemperature, capacity: capacity.capacity.sensible)
  }
}

fileprivate func interpolateCapacity(
  outdoorDesignTemperature: Int,
  below: OneWayEnvelope,
  above: OneWayEnvelope
) async -> Int {
  below.capacity
  - (outdoorDesignTemperature - below.outdoorTemperature)
  * ((below.capacity - above.capacity) / (above.outdoorTemperature - below.outdoorTemperature))
}

fileprivate extension CoolingCapacity {
  
  mutating func adjust(excessLatent: Int) async {
    sensible += excessLatent
  }
  
  mutating func apply(multiplier: AdjustmentMultiplier) async {
    guard case let .airToAir(total: totalMultiplier, sensible: sensibleMultiplier, heating: _) = multiplier else {
      return
    }
    let total = Double(self.total) * totalMultiplier
    let sensible = Double(self.sensible) * sensibleMultiplier
    
    self.total = Int(total)
    self.sensible = Int(sensible)
  }
}

fileprivate extension CapacityAsPercentOfLoad {
  
  init(houseLoad: HouseLoad, finalCapacity: CoolingCapacity) {
    self.init(
      total: .normalizePercentage(Double(finalCapacity.total) / Double(houseLoad.cooling.total)),
      sensible: .normalizePercentage(Double(finalCapacity.sensible) / Double(houseLoad.cooling.sensible)),
      latent: .normalizePercentage(Double(finalCapacity.latent) / Double(houseLoad.cooling.latent))
    )
  }
}
