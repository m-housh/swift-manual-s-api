import XCTest
import CustomDump
import Dependencies
import Models
import ApiRouteMiddlewareLive
import FirstPartyMocks

@MainActor
final class BalancePointTests: XCTestCase {
  
  func test_thermalBalancePoint() async throws {
    try await withLiveSiteHandler {
      @Dependency(\.apiMiddleware) var client
      let request = ServerRoute.Api.Route.balancePoint(.thermal(.init(designTemperature: 5, heatLoss: 49_667, capacity: .mock)))
      let expected = BalancePointResponse(balancePoint: 38.5)
      let sut2 = try await client.respond(.init(isDebug: true, route: request))
      XCTAssertNotNil(sut2.value as? BalancePointResponse)
      XCTAssertNoDifference(sut2.value as! BalancePointResponse, expected)
    }
  }

}
