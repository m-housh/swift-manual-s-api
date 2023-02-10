import Foundation
import Models
import Validations

extension ServerRoute.Api.Route.SizingLimitRequest {

  func respond() async throws -> SizingLimits {
    try await self.systemType.sizingLimits(load: self.houseLoad)
  }
}

extension SystemType {

  fileprivate func sizingLimits(load: HouseLoad?) async throws -> SizingLimits {
    switch self {
    case let .airToAir(type: _, compressor: compressor, climate: climate):
      let coolingTotal: Int
      switch (compressor, climate) {
      case (.singleSpeed, .mildWinterOrLatentLoad):
        coolingTotal = 115
      case (.multiSpeed, .mildWinterOrLatentLoad):
        coolingTotal = 120
      case (.variableSpeed, .mildWinterOrLatentLoad):
        coolingTotal = 130
      default:
        guard let load = load else {
          throw ValidationError(summary: "Must supply a house load.")
        }
        let decimal = Double(load.cooling.total + 15_000) / Double(load.cooling.total)
        coolingTotal = Int(round(decimal * 100))
      }
      return .init(oversizing: .cooling(total: coolingTotal), undersizing: .cooling())
    case .furnaceOnly:
      return .init(oversizing: .furnace(), undersizing: .furnace())
    case .boilerOnly:
      return .init(oversizing: .boiler(), undersizing: .boiler())
    }
  }
}
