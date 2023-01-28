import Models
import Foundation

extension ServerRoute.Api.Route.BalancePointRequest {

  func respond() async throws -> BalancePointResponse {
    switch self {
    case let .thermal(designTemperature: designTemperature, heatLoss: heatLoss, capacity: heatPumpCapacity):
      let balancePoint = await thermalBalancePoint(
        heatLoss: heatLoss,
        at47: Double(heatPumpCapacity.at47),
        at17: Double(heatPumpCapacity.at17),
        designTemperature: designTemperature
      )
      
      return .init(balancePoint: round(balancePoint * 10.0) / 10.0)
      
    }
  }
}

//extension ServerRoute.Api.Route.BalancePointRequest {
  
  fileprivate func thermalBalancePoint(
    heatLoss: Double,
    at47: Double,
    at17: Double,
    designTemperature: Double
  ) async -> Double {
    (30.0 * (((designTemperature - 65.0) * at47) + (65.0 * heatLoss))
              - ((designTemperature  - 65.0) * (at47  - at17) * 47.0))
    / ((30.0 * heatLoss) - ((designTemperature - 65.0) * (at47  - at17)))
  }
  
//  fileprivate func balancePoint() async throws -> Double {
//    let balancePoint = await thermalBalancePoint(
//      heatLoss: heatLoss,
//      at47: Double(heatPumpCapacity.at47),
//      at17: Double(heatPumpCapacity.at17),
//      designTemperature: winterDesignTemperature
//    )
//
//    return round(balancePoint * 10.0) / 10.0
//  }
//}
