import Foundation
import Models
import Validations
//import UtilsClient

extension ServerRoute.Api.Route.RequiredKW {
  func respond() async throws -> RequiredKWResponse {
//    try await RequiredKWValidator(request: self).validate()
    try await self.validate()
    let result = (heatLoss - capacityAtDesign) / 3413
    return .init(requiredKW: round(result * 100) / 100)
  }
}

extension ServerRoute.Api.Route.RequiredKW: Validatable {
  
  public var body: some Validator<Self> {
    GreaterThan(\.heatLoss, 0)
    GreaterThanOrEquals(\.capacityAtDesign, 0)
  }
}

//fileprivate struct RequiredKWValidator: Validator, Validatable {
//
//  typealias Value = ServerRoute.Api.Route.RequiredKW
//  let request: ServerRoute.Api.Route.RequiredKW
//
//  var body: some Validator<Value> {
//    GreaterThan(\.heatLoss, 0)
//  }
//
//  func validate() async throws {
//    try await self.validate(self.request)
//  }
//}
