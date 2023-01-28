import Models

extension ServerRoute.Api.Route.InterpolationRequest.Cooling {
  
  func respond() async throws ->  InterpolationResponse.Cooling {
    switch self {
    case let .noInterpolation(noInterpolation):
      return try await interpolate(noInterpolation: noInterpolation)
    case let .oneWayIndoor(oneWayIndoor):
      return try await interpolate(oneWayIndoor: oneWayIndoor)
    case let .oneWayOutdoor(oneWayOutdoor):
      return try await interpolate(oneWayOutdoor: oneWayOutdoor)
    case let .twoWay(twoWay):
      return try await interpolate(twoWay: twoWay)
    }
  }
}

// MARK: - Validations
fileprivate extension CoolingCapacityEnvelope {

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

fileprivate extension ServerRoute.Api.Route.InterpolationRequest.Cooling.TwoWayRequest.CapacityEnvelope {
  
  func validate() async throws {
    guard above.cfm == below.cfm else {
      throw ValidationError("Above cfm should match below cfm.")
    }
    guard above.indoorTemperature == below.indoorTemperature else {
      throw ValidationError("Above indoor temperature should match below indoor temperature.")
    }
    guard above.indoorWetBulb > below.indoorWetBulb else {
      throw ValidationError("Above indoor wet-bulb should be greater than below indoor wet-bulb.")
    }
    guard above.indoorWetBulb > 63 else {
      throw ValidationError("Above indoor wet-bulb should be greater than 63°.")
    }
    guard below.indoorWetBulb < 63 else {
      throw ValidationError("Below indoor wet-bulb should be less than 63°.")
    }
    
    try await above.validate()
    try await below.validate()
  }
}

fileprivate extension ServerRoute.Api.Route.InterpolationRequest.Cooling.TwoWayRequest {
  
  func validate() async throws {
    guard belowDesign.below.outdoorTemperature < designInfo.summer.outdoorTemperature else {
      throw ValidationError("Below design, below outdoor temperature should be less than design outdoor temperature.")
    }
    guard aboveDesign.below.cfm == belowDesign.below.cfm else {
      throw ValidationError("Above design, below cfm should match below design, below cfm.")
    }
    guard belowDesign.below.indoorTemperature == designInfo.summer.indoorTemperature else {
      throw ValidationError("Below design, below indoor temperature should match design indoor temperature.")
    }
    guard aboveDesign.below.indoorTemperature == designInfo.summer.indoorTemperature else {
      throw ValidationError("Above design, below indoor temperature should match design indoor temperature.")
    }
    try await aboveDesign.validate()
    try await belowDesign.validate()
  }
}

fileprivate extension ServerRoute.Api.Route.InterpolationRequest.Cooling.OneWayRequest {
  
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
  
  func validateOneWayIndoor() async throws {
    guard aboveDesign.cfm == belowDesign.cfm else {
      throw ValidationError("Above design CFM and below design CFM")
    }
    guard aboveDesign.outdoorTemperature == belowDesign.outdoorTemperature else {
      throw ValidationError("Above design and below design outdoor temperatures should match.")
    }
    guard aboveDesign.indoorTemperature == belowDesign.indoorTemperature else {
      throw ValidationError("Above design and below design indoor temperatures should match.")
    }
    guard belowDesign.indoorWetBulb < 63 else {
      throw ValidationError("Below design indoor wet-bulb should be below 63°.")
    }
    guard aboveDesign.indoorWetBulb > 63 else {
      throw ValidationError("Above design indoor wet-bulb should be above 63°.")
    }
    
    try await aboveDesign.validate()
    try await belowDesign.validate()
  }
}

fileprivate extension ServerRoute.Api.Route.InterpolationRequest.Cooling.NoInterpolationRequest {
  
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

// MARK: - Interpolations

fileprivate extension ServerRoute.Api.Route.InterpolationRequest.Cooling {
  
  func interpolate(noInterpolation: NoInterpolationRequest) async throws -> InterpolationResponse.Cooling {
    try await noInterpolation.validate()
    let envelope = try await CoolingInterpolationEnvelope(
      interpolatedCapacity: noInterpolation.capacity.capacity,
      request: noInterpolation
    )
    return .init(envelope: envelope)
  }
  
  func interpolate(oneWayOutdoor: OneWayRequest) async throws -> InterpolationResponse.Cooling {
    try await oneWayOutdoor.validateOneWayOutdoor()
    let inerpolatedCapacity = await oneWayOutdoor.interpolated(for: .outdoor)
    let envelope = try await CoolingInterpolationEnvelope(
      interpolatedCapacity: inerpolatedCapacity,
      request: oneWayOutdoor
    )
    return .init(envelope: envelope)
  }
  
  func interpolate(oneWayIndoor: OneWayRequest) async throws -> InterpolationResponse.Cooling {
    try await oneWayIndoor.validateOneWayIndoor()
    let interpolatedCapacity = await oneWayIndoor.interpolated(for: .indoor)
    let envelope = try await CoolingInterpolationEnvelope(
      interpolatedCapacity: interpolatedCapacity,
      request: oneWayIndoor
    )
    return .init(envelope: envelope)
  }
  
  func interpolate(twoWay: TwoWayRequest) async throws -> InterpolationResponse.Cooling {
    try await twoWay.validate()
    let aboveIndoorResult = try await interpolate(
      oneWayIndoor: twoWay.aboveDesign.oneWayIndoorRequest(twoWay)
    )
    let belowIndoorResult = try await interpolate(
      oneWayIndoor: twoWay.belowDesign.oneWayIndoorRequest(twoWay)
    )
    let outdoorRequest = twoWay.outdoorRequest(above: aboveIndoorResult.result, below: belowIndoorResult.result)
    let outdoorResult = try await interpolate(oneWayOutdoor: outdoorRequest)
    return outdoorResult
//    return outdoorResult.result(request: .twoWay(twoWay))
  }
}

// MARK: - Helpers

fileprivate extension InterpolationResponse.Cooling.Result {
  
  init(envelope: CoolingInterpolationEnvelope) {
    self.init(
      interpolatedCapacity: envelope.interpolatedCapacity,
      excessLatent: envelope.excessLatent,
      finalCapacityAtDesign: envelope.finalCapacity,
      altitudeDerating: envelope.altitudeDerating,
      capacityAsPercentOfLoad: envelope.capacityAsPercentOfLoad
    )
  }
}

fileprivate extension InterpolationResponse.Cooling {
  init(envelope: CoolingInterpolationEnvelope) {
    self.init(result: .init(envelope: envelope))
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
    let deratingRequest = ServerRoute.Api.Route.Derating(
      elevation: designInfo.elevation,
      systemType: systemType
    )
    return try await deratingRequest.respond()
//    return try await utils.derating(.init(systemType: systemType, elevation: designInfo.elevation))
  }
}

fileprivate extension ServerRoute.Api.Route.InterpolationRequest.Cooling.TwoWayRequest.CapacityEnvelope {
  
  func oneWayIndoorRequest(_ request: any CoolingInterpolationRequest) -> ServerRoute.Api.Route.InterpolationRequest.Cooling.OneWayRequest {
    .init(
      aboveDesign: above,
      belowDesign: below,
      designInfo: request.designInfo,
      houseLoad: request.houseLoad,
      systemType: request.systemType
    )
  }
}

fileprivate extension ServerRoute.Api.Route.InterpolationRequest.Cooling.TwoWayRequest {
  func outdoorRequest(
    above: InterpolationResponse.Cooling.Result,
    below: InterpolationResponse.Cooling.Result
  ) -> ServerRoute.Api.Route.InterpolationRequest.Cooling.OneWayRequest {
    .init(
      aboveDesign: .init(
        cfm: aboveDesign.above.cfm,
        indoorTemperature: aboveDesign.above.indoorTemperature,
        indoorWetBulb: 63,
        outdoorTemperature: aboveDesign.above.outdoorTemperature,
        capacity: above.interpolatedCapacity
      ),
      belowDesign: .init(
        cfm: belowDesign.above.cfm,
        indoorTemperature: belowDesign.above.indoorTemperature,
        indoorWetBulb: 63,
        outdoorTemperature: belowDesign.below.outdoorTemperature,
        capacity: below.interpolatedCapacity
      ),
      designInfo: designInfo,
      houseLoad: houseLoad,
      systemType: systemType
    )
  }
}

fileprivate extension ServerRoute.Api.Route.InterpolationRequest.Cooling.OneWayRequest {
  
  enum InterpolationType {
    case indoor
    case outdoor
  }
  
  func interpolated(for location: InterpolationType) async -> CoolingCapacity {
    switch location {
    case .indoor:
      return await _interpolatedIndoorCapacity()
    case .outdoor:
      return await _interpolatedOutdoorCapacity()
    }
  }
  
  private func _interpolatedIndoorCapacity() async -> CoolingCapacity {
    let total = belowDesign.capacity.total
    + ((aboveDesign.capacity.total - belowDesign.capacity.total) / (aboveDesign.indoorWetBulb - belowDesign.indoorWetBulb))
      * (63 - belowDesign.indoorWetBulb)
    
    // This one gives improper results when it does not use Doubles.
    let sensible = Int(
      Double(belowDesign.capacity.sensible)
      + ((Double(aboveDesign.capacity.sensible) - Double(belowDesign.capacity.sensible))
      / (Double(belowDesign.capacity.total) - Double(aboveDesign.capacity.total)))
      * (Double(belowDesign.capacity.total) - Double(total))
    )
    
    return .init(total: total, sensible: sensible)
  }

  private func _interpolatedOutdoorCapacity() async -> CoolingCapacity {
    let total = await OneWayOutdoorEnvelope.interpolateCapacity(
      outdoorDesignTemperature: designInfo.summer.outdoorTemperature,
      below: .total(belowDesign),
      above: .total(aboveDesign)
    )
    let sensible = await OneWayOutdoorEnvelope.interpolateCapacity(
      outdoorDesignTemperature: designInfo.summer.outdoorTemperature,
      below: .sensible(belowDesign),
      above: .sensible(aboveDesign)
    )

    return .init(total: total, sensible: sensible)
  }
}

fileprivate struct OneWayOutdoorEnvelope {
  let outdoorTemperature: Int
  let capacity: Int
  
  static func total(_ capacity: CoolingCapacityEnvelope) -> Self {
    .init(outdoorTemperature: capacity.outdoorTemperature, capacity: capacity.capacity.total)
  }
  
  static func sensible(_ capacity: CoolingCapacityEnvelope) -> Self {
    .init(outdoorTemperature: capacity.outdoorTemperature, capacity: capacity.capacity.sensible)
  }
  
  static func interpolateCapacity(
    outdoorDesignTemperature: Int,
    below: OneWayOutdoorEnvelope,
    above: OneWayOutdoorEnvelope
  ) async -> Int {
    below.capacity
    - (outdoorDesignTemperature - below.outdoorTemperature)
    * ((below.capacity - above.capacity) / (above.outdoorTemperature - below.outdoorTemperature))
  }
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
