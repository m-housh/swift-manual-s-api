import Foundation
import Models

extension ServerRoute.Api.Route.SizingLimit {

  func respond() async throws -> SizingLimits {
    try await self.systemType.sizingLimits(load: self.houseLoad)
  }
}

extension SystemType {

  func sizingLimits(load: HouseLoad?) async throws -> SizingLimits {
    switch self {
    case let .airToAir(airToAir):
      let coolingTotal: Int
      switch (airToAir.compressor, airToAir.climate) {
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
    case let .heatingOnly(heatingOnly):
      switch heatingOnly {
      case .boiler:
        return .init(oversizing: .boiler(), undersizing: .boiler())
      case .furnace:
        return .init(oversizing: .furnace(), undersizing: .furnace())
      case .electric:
        return .init(oversizing: .furnace(), undersizing: .furnace())
      }
    }
  }
}
