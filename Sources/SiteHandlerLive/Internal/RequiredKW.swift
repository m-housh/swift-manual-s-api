import Foundation
import Models
//import UtilsClient

extension ServerRoute.Api.Route.RequiredKW {
  func respond() async throws -> RequiredKWResponse {
    let result = (heatLoss - capacityAtDesign) / 3413
    return .init(requiredKW: round(result * 100) / 100)
  }
}
