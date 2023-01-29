import Models
import Foundation
import Validations

extension ServerRoute.Api.Route.BalancePointRequest {

  func respond() async throws -> BalancePointResponse {
    switch self {
    case let .thermal(thermalRequest):
      try await thermalRequest.validate()
      
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

extension ServerRoute.Api.Route.BalancePointRequest.Thermal: Validatable {

  public typealias Value = Self

  public var body: some Validator<Self> {
    ValidatorOf<Self> {
      GreaterThan(\.heatLoss, 0)
      Validate(\.capacity)
    }
  }
}
