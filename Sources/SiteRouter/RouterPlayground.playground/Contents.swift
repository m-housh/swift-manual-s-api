import FirstPartyMocks
import Foundation
import Models

let model = ServerRoute.Api.Route.Interpolation.init(
  designInfo: .mock,
  houseLoad: .mock,
  systemType: .default,
  route: .keyed(.mocks)
)
//let model = ServerRoute.Api.Route.Interpolation.Route.Cooling.noInterpolation(.init(capacity: .mock, manufacturerAdjustments: nil))
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

let encoded = try encoder.encode(model)

print(String(data: encoded, encoding: .utf8)!)
//
//let decoder = JSONDecoder()
//let decoded = try decoder.decode(ServerRoute.Api.Route.Interpolation.self, from: encoded)
//print("\(decoded)")
