import Models

extension ServerRoute.Api.Route.Interpolation.Cooling {
  
  func respond() async throws ->  InterpolationResponse {
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

// MARK: - Interpolations

fileprivate extension ServerRoute.Api.Route.Interpolation.Cooling {
  
  func interpolate(noInterpolation: NoInterpolation) async throws -> InterpolationResponse {
    let envelope = try await CoolingInterpolationEnvelope(
      interpolatedCapacity: noInterpolation.capacity.capacity,
      request: noInterpolation
    )
    return try await .init(envelope: envelope)
  }
  
  func interpolate(oneWayOutdoor: OneWay) async throws -> InterpolationResponse {
    let inerpolatedCapacity = await oneWayOutdoor.interpolated(for: .outdoor)
    let envelope = try await CoolingInterpolationEnvelope(
      interpolatedCapacity: inerpolatedCapacity,
      request: oneWayOutdoor
    )
    return try await .init(envelope: envelope)
  }
  
  func interpolate(oneWayIndoor: OneWay) async throws -> InterpolationResponse {
    let interpolatedCapacity = await oneWayIndoor.interpolated(for: .indoor)
    let envelope = try await CoolingInterpolationEnvelope(
      interpolatedCapacity: interpolatedCapacity,
      request: oneWayIndoor
    )
    return try await .init(envelope: envelope)
  }
  
  func interpolate(twoWay: TwoWay) async throws -> InterpolationResponse {
    guard case let .cooling(aboveIndoorResult) = try await interpolate(
      oneWayIndoor: twoWay.aboveDesign.oneWayIndoorRequest(twoWay)
    ).result
    else {
      // throw an error
      fatalError()
    }
    
    guard case let .cooling(belowIndoorResult) = try await interpolate(
      oneWayIndoor: twoWay.belowDesign.oneWayIndoorRequest(twoWay)
    ).result
    else {
      fatalError()
    }
    
    let outdoorRequest = twoWay.outdoorRequest(above: aboveIndoorResult.result, below: belowIndoorResult.result)
    let outdoorResult = try await interpolate(oneWayOutdoor: outdoorRequest)
    return outdoorResult
  }
}

// MARK: - Helpers
fileprivate extension InterpolationResponse {
  
  init(envelope: CoolingInterpolationEnvelope) async throws {
    let coolingResult = InterpolationResult.Cooling(envelope: envelope)
    let failures = envelope.sizingLimits.validate(envelope.capacityAsPercentOfLoad)
    self.init(
      failures: failures,
      result: .cooling(coolingResult)
    )
  }
}

fileprivate extension InterpolationResult.Cooling.Result {
  
  init(envelope: CoolingInterpolationEnvelope) {
    self.init(
      interpolatedCapacity: envelope.interpolatedCapacity,
      excessLatent: envelope.excessLatent,
      finalCapacityAtDesign: envelope.finalCapacity,
      altitudeDerating: envelope.altitudeDerating,
      capacityAsPercentOfLoad: envelope.capacityAsPercentOfLoad,
      sizingLimits: envelope.sizingLimits
    )
  }
}

fileprivate extension InterpolationResult.Cooling {
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
  let sizingLimits: SizingLimits
  
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
    self.sizingLimits = try await request.systemType.sizingLimits(load: request.houseLoad)
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
  }
}

fileprivate extension ServerRoute.Api.Route.Interpolation.Cooling.TwoWay.CapacityEnvelope {
  
  func oneWayIndoorRequest(
    _ request: any CoolingInterpolationRequest
  ) -> ServerRoute.Api.Route.Interpolation.Cooling.OneWay {
    .init(
      aboveDesign: aboveWetBulb,
      belowDesign: belowWetBulb,
      designInfo: request.designInfo,
      houseLoad: request.houseLoad,
      systemType: request.systemType
    )
  }
}

fileprivate extension ServerRoute.Api.Route.Interpolation.Cooling.TwoWay {
  func outdoorRequest(
    above: InterpolationResult.Cooling.Result,
    below: InterpolationResult.Cooling.Result
  ) -> ServerRoute.Api.Route.Interpolation.Cooling.OneWay {
    .init(
      aboveDesign: .init(
        cfm: aboveDesign.aboveWetBulb.cfm,
        indoorTemperature: aboveDesign.aboveWetBulb.indoorTemperature,
        indoorWetBulb: 63,
        outdoorTemperature: aboveDesign.aboveWetBulb.outdoorTemperature,
        capacity: above.interpolatedCapacity
      ),
      belowDesign: .init(
        cfm: belowDesign.aboveWetBulb.cfm,
        indoorTemperature: belowDesign.aboveWetBulb.indoorTemperature,
        indoorWetBulb: 63,
        outdoorTemperature: belowDesign.belowWetBulb.outdoorTemperature,
        capacity: below.interpolatedCapacity
      ),
      designInfo: designInfo,
      houseLoad: houseLoad,
      systemType: systemType
    )
  }
}

fileprivate extension ServerRoute.Api.Route.Interpolation.Cooling.OneWay {
  
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
  
  static func total(_ capacity: ManufactuerCoolingCapacity) -> Self {
    .init(outdoorTemperature: capacity.outdoorTemperature, capacity: capacity.capacity.total)
  }
  
  static func sensible(_ capacity: ManufactuerCoolingCapacity) -> Self {
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

extension SizingLimits {
  
  private func validateOversizing(_ capacity: CapacityAsPercentOfLoad) -> [String]? {
    
    guard case let .cooling(total: oversizingTotal, latent: oversizingLatent) = self.oversizing else {
      return ["Invalid sizing limits: \(self)"]
    }
    
    var failures = [String]()
    
    if capacity.total > Double(oversizingTotal) {
      failures.append("Oversizing total failure")
    }
    if capacity.latent > Double(oversizingLatent) {
      failures.append("Oversizing latent failure.")
    }
    return failures.isEmpty ? nil : failures
  }
  
  private func validateUndersizing(_ capacity: CapacityAsPercentOfLoad) -> [String]? {
    guard case let .cooling(
      total: undersizingTotal,
      sensible: undersizingSensible,
      latent: undersizingLatent
    ) = self.undersizing else {
      return ["Invalid sizing limits: \(self)"]
    }
    
    var failures = [String]()
    
    if capacity.total < Double(undersizingTotal) {
      failures.append("Undersizing total failure.")
    }
    if capacity.sensible < Double(undersizingSensible) {
      failures.append("Undersizing sensible failure.")
    }
    if capacity.latent < Double(undersizingLatent) {
      failures.append("Undersizing latent failure.")
    }
    
    return failures.isEmpty ? nil : failures
  }
  
  func validate(_ capacityAsPercentOfLoad: CapacityAsPercentOfLoad) -> [String]? {
    var failures = [String]()
    
    if let oversizingFailures = validateOversizing(capacityAsPercentOfLoad) {
      failures += oversizingFailures
    }
    if let undersizingFailures = validateUndersizing(capacityAsPercentOfLoad) {
      failures += undersizingFailures
    }
    
    return failures.isEmpty ? nil : failures
  }
}
