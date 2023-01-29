import Foundation
import Models
import Validations
import Dependencies
//import UtilsClient

extension ServerRoute.Api.Route.RequiredKWRequest {
  func respond() async throws -> RequiredKWResponse {
//    try await self.validate()
    let result = (heatLoss - capacityAtDesign) / 3413
    return .init(requiredKW: round(result * 100) / 100)
  }
}

//extension ServerRoute.Api.Route.RequiredKWRequest: AsyncValidatable {
//  
//  public var body: some AsyncValidator<Self> {
//    AsyncValidation {
//      GreaterThan(\.heatLoss, 0)
//      GreaterThanOrEquals(\.capacityAtDesign, 0)
//    }
//  }
//}
