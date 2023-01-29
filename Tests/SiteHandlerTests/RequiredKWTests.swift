import XCTest
import Models
import SiteHandlerLive

final class RequiredKWTests: XCTestCase {
  
  let client = SiteHandler.live
  
  func test_requiredKW() async throws {
    let sut = try await client.api.requiredKW(.init(capacityAtDesign: 0, heatLoss: Double(HouseLoad.mock.heating)))
    XCTAssertEqual(sut, .init(requiredKW: 14.55))
    
    let sut2 = try await client.api.requiredKW(.init(capacityAtDesign: 11_300, heatLoss: Double(HouseLoad.mock.heating)))
    XCTAssertEqual(sut2.requiredKW, 11.24)
  }
  
  func test_requiredKW_validations() async {
    await XCTAssertThrowsError(
      try await ServerRoute.Api.Route.RequiredKW(
        capacityAtDesign: 0,
        heatLoss: 0
      ).validate()
    )
    await XCTAssertThrowsError(
      try await ServerRoute.Api.Route.RequiredKW(
        capacityAtDesign: -1,
        heatLoss: 1234
      ).validate()
    )
  }
}

