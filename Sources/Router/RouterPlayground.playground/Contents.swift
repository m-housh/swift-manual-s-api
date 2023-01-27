import Foundation
import Models


let model = ServerRoute.Api.Route.InterpolationRequest.Cooling.TwoWayRequest(
  aboveDesign: .init(
    above: .init(
      cfm: 800,
      indoorTemperature: 75,
      indoorWetBulb: 67,
      outdoorTemperature: 95,
      capacity: .init(total: 24_828, sensible: 15_937)
    ),
    below: .init(
      cfm: 800,
      indoorTemperature: 75,
      indoorWetBulb: 62,
      outdoorTemperature: 95,
      capacity: .init(total: 23_046, sensible: 19_078)
    )
  ),
  belowDesign: .init(
    above: .init(
      cfm: 800,
      indoorTemperature: 75,
      indoorWetBulb: 67,
      outdoorTemperature: 85,
      capacity: .init(total: 25_986, sensible: 16_330)
    ),
    below: .init(
      cfm: 800,
      indoorTemperature: 75,
      indoorWetBulb: 62,
      outdoorTemperature: 85,
      capacity: .init(total: 24_029, sensible: 19_605)
    )
  ),
  designInfo: .mock,
  houseLoad: .mock,
  systemType: .default
)

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

let encoded = try encoder.encode(model)

print(String(data: encoded, encoding: .utf8)!)
