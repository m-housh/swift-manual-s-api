import Dependencies
import Foundation
import Models

extension ServerRoute.Api.Route.RequiredKW {
  @inlinable
  func respond() async throws -> RequiredKWResponse {
    try await RequiredKWRequestEnvelope(request: self).respond()
  }
}

// HACK bc optional capacity at design fails for some reason.
@usableFromInline
struct RequiredKWRequestEnvelope {
  let heatLoss: Double
  let capacityAtDesign: Double

  @usableFromInline
  init(request: ServerRoute.Api.Route.RequiredKW) {
    self.heatLoss = request.heatLoss
    self.capacityAtDesign = request.capacityAtDesign ?? 0.0
  }

  @usableFromInline
  func respond() async throws -> RequiredKWResponse {
    let result = (heatLoss - capacityAtDesign) / 3413
    return .init(requiredKW: round(result * 100) / 100)
  }
}
