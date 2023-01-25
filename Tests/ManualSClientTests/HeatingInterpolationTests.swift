import XCTest
import ManualSClient
import ManualSClientLive

final class HeatingInterpolationTests: XCTestCase {
  
  let client = ManualSClient.live
  
  func test_furnace() async throws {
    let request = ManualSClient.HeatingInterpolation.FurnaceRequest(
      altitudeDeratings: nil,
      houseLoad: .mock,
      input: 60_000,
      afue: 96
    )
    let sut = try await client.heatingInterpolation(.furnace(request))
    XCTAssertEqual(sut, .furnace(.init(request: request, outputCapacity: 57_600, finalCapacity: 57_600, percentOfLoad: 116)))
  }
  
  func test_boiler() async throws {
    let request = ManualSClient.HeatingInterpolation.BoilerRequest(
      altitudeDeratings: nil,
      houseLoad: .mock,
      input: 60_000,
      afue: 96
    )
    let sut = try await client.heatingInterpolation(.boiler(request))
    XCTAssertEqual(sut, .boiler(.init(request: request, outputCapacity: 57_600, finalCapacity: 57_600, percentOfLoad: 116)))
  }
}
