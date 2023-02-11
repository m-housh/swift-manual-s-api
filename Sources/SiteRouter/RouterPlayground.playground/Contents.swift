import FirstPartyMocks
import Foundation
import Models

let model = ServerRoute.Api.Route.InterpolationRequest.Heating.heatPump(
  .init(
    altitudeDeratings: .airToAir(total: 1, sensible: 1, heating: 1),
    capacity: .mock,
    designInfo: .mock,
    houseLoad: .mock
  ))

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

let encoded = try encoder.encode(model)

print(String(data: encoded, encoding: .utf8)!)
