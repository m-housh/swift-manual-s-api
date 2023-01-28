import XCTest
import SiteHandlerLive
import CustomDump

final class BalancePointTests: XCTestCase {
  
  let client = SiteHandler.live
  
  func test_thermalBalancePoint() async throws {
    let sut = try await client.api.balancePoint(.thermal(designTemperature: 5, heatLoss: 49_667, capacity: .mock))
    XCTAssertNoDifference(sut.balancePoint, 38.5)
  }
}
