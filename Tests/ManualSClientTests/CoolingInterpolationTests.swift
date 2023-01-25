import XCTest
import ManualSClient
import ManualSClientLive

final class CoolingInterpolationTests: XCTestCase {
  
  let client = ManualSClient.live
  
  func test_noInterpolation() async throws {
    let request = ManualSClient.CoolingInterpolation.NoInterpolationRequest(
      capacity: .init(
        cfm: 800,
        indoorTemperature: 75,
        indoorWetBulb: 63,
        outdoorTemperature: 90,
        capacity: .init(total: 22_600, sensible: 16_850)
      ),
      designInfo: .init(),
      houseLoad: .init(heating: 49_667, cooling: .init(total: 17_872, sensible: 13_894)),
      manufacturerAdjustments: nil,
      systemType: .default
    )
    
    let sut = try await client.interpolate(.cooling(.noInterpolation(request)))
    
    XCTAssertEqual(sut, .cooling(.init(
      request: .noInterpolation(request),
      interpolatedCapacity: request.capacity.capacity,
      excessLatent: 886,
      finalCapacityAtDesign: .init(total: 22_600, sensible: 17_736),
      altitudeDerating: .airToAir(total: 1, sensible: 1, heating: 1),
      capacityAsPercentOfLoad: .init(total: 126.5, sensible: 127.7, latent: 122.3)))
    )
  }
}
