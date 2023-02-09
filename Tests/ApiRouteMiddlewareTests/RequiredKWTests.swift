import XCTest
import Dependencies
import Models
import ApiRouteMiddlewareLive
import FirstPartyMocks

final class RequiredKWTests: XCTestCase {
  
  func test_requiredKW() async throws {
    try await withLiveSiteHandler {
      @Dependency(\.apiMiddleware) var client
      let sut = try await client.respond(.init(
        isDebug: true,
        route: .requiredKW(.init(capacityAtDesign: 0, heatLoss: Double(HouseLoad.mock.heating)))
      )).value as! RequiredKWResponse
      
      XCTAssertEqual(sut, .init(requiredKW: 14.55))
      
      let sut2 = try await client.respond(.init(
        isDebug: true,
        route: .requiredKW(.init(capacityAtDesign: 11_300, heatLoss: Double(HouseLoad.mock.heating)))
      )).value as! RequiredKWResponse
      
      XCTAssertEqual(sut2.requiredKW, 11.24)
    }
  }
  
}

