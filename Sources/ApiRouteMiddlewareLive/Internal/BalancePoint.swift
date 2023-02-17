import Foundation
import Models

extension ServerRoute.Api.Route.BalancePoint {

  func respond() async throws -> BalancePointResponse {
    switch self {
    case let .thermal(thermalRequest):
      //      try await thermalRequest.validate()

      let balancePoint = await thermalBalancePoint(
        heatLoss: thermalRequest.heatLoss,
        at47: Double(thermalRequest.capacity.at47),
        at17: Double(thermalRequest.capacity.at17),
        designTemperature: thermalRequest.designTemperature
      )

      return .init(balancePoint: round(balancePoint * 10.0) / 10.0)

    }
  }
}

private func thermalBalancePoint(
  heatLoss: Double,
  at47: Double,
  at17: Double,
  designTemperature: Double
) async -> Double {
  (30.0 * (((designTemperature - 65.0) * at47) + (65.0 * heatLoss))
    - ((designTemperature - 65.0) * (at47 - at17) * 47.0))
    / ((30.0 * heatLoss) - ((designTemperature - 65.0) * (at47 - at17)))
}
