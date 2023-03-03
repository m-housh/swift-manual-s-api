import FirstPartyMocks
import Foundation
import Models

let model = ServerRoute.Api.Route.Interpolation.init(
  designInfo: .mock,
  houseLoad: .mock,
  systemType: .default,
  route: .cooling(route: .noInterpolation(.mock))
)
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

let encoded = try encoder.encode(model)

print(String(data: encoded, encoding: .utf8)!)

let decoded = try JSONDecoder().decode(ServerRoute.Api.Route.Interpolation.self, from: encoded)
assert(decoded == model)
