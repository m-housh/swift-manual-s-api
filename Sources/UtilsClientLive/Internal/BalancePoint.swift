import UtilsClient
import Foundation

extension UtilsClient.BalancePointRequest {
  
  func run() async throws -> UtilsClient.BalancePointResponse {
    switch self {
    case let .thermal(thermalRequest):
      return .init(balancePoint: try await thermalRequest.balancePoint())
    }
  }
}

fileprivate extension UtilsClient.BalancePointRequest.ThermalBalancePointRequest {
  
  func thermalBalancePoint(
    heatLoss: Double,
    at47: Double,
    at17: Double,
    designTemperature: Double
  ) async -> Double {
    (30.0 * (((designTemperature - 65.0) * at47) + (65.0 * heatLoss))
              - ((designTemperature  - 65.0) * (at47  - at17) * 47.0))
    / ((30.0 * heatLoss) - ((designTemperature - 65.0) * (at47  - at17)))
  }
  
  func balancePoint() async throws -> Double {
    let balancePoint = await thermalBalancePoint(
      heatLoss: heatLoss,
      at47: Double(heatPumpCapacity.at47),
      at17: Double(heatPumpCapacity.at17),
      designTemperature: winterDesignTemperature
    )
    
    return round(balancePoint * 10.0) / 10.0
  }
}
