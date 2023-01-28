import XCTest
import Models
import SiteHandlerLive
import CustomDump

final class BalancePointTests: XCTestCase {
  
  let client = SiteHandler.live
  
  func test_thermalBalancePoint() async throws {
    let request = ServerRoute.Api.Route.balancePoint(.thermal(designTemperature: 5, heatLoss: 49_667, capacity: .mock))
    let sut = try await client.api.balancePoint(.thermal(designTemperature: 5, heatLoss: 49_667, capacity: .mock))
    let expected = BalancePointResponse(balancePoint: 38.5)
    
    XCTAssertNoDifference(sut, expected)
    
    let sut2 = try await client.respond(.api(.init(isDebug: true, route: request)))
    XCTAssertNotNil(sut2.value as? BalancePointResponse)
    XCTAssertNoDifference(sut2.value as? BalancePointResponse, expected)
    
  }
}
