import Foundation
import Models
import SizingLimitClient

extension SizingLimitClient {
  
  public static let live = Self.init(
    sizingLimits: { try await $0.run() }
  )
  
}

fileprivate extension SizingLimitClient.Request.SizingLimits {
  
  func run() async throws -> SizingLimitClient.SizingLimits {
    try await systemType.sizingLimits(load: self.houseLoad)
  }
}

fileprivate extension SystemType {
  
  func sizingLimits(load: HouseLoad?) async throws -> SizingLimitClient.SizingLimits {
    switch self {
    case let .airToAir(type: _, compressor: compressor, climate: climate):
      let coolingTotal: Int
      switch  (compressor, climate) {
      case (.singleSpeed, .mildWinterOrLatentLoad):
        coolingTotal = 115
      case (.multiSpeed, .mildWinterOrLatentLoad):
        coolingTotal = 120
      case (.variableSpeed, .mildWinterOrLatentLoad):
        coolingTotal = 130
      default:
        guard let load = load else { throw SizingLimitError() }
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

public struct SizingLimitError: Error {
  public init() { }
}
