import XCTest
import CustomDump
import Dependencies
import Models
import SiteHandlerLive
import SiteRouteValidationsLive
import TestSupport

final class BalancePointTests: XCTestCase {
  
  func test_thermalBalancePoint() async throws {
    try await withLiveSiteHandler {
      
      @Dependency(\.siteValidator) var validator: SiteRouteValidator
      @Dependency(\.siteHandler) var client: SiteHandler
      
      let request = ServerRoute.Api.Route.balancePoint(.thermal(.init(designTemperature: 5, heatLoss: 49_667, capacity: .mock)))
      
      let expected = BalancePointResponse(balancePoint: 38.5)
      
      let serverRoute = ServerRoute.api(.init(isDebug: true, route: request))
      try await validator.validate(serverRoute)
      
      let sut2 = try await client.respond(.api(.init(isDebug: true, route: request)))
      XCTAssertNotNil(sut2.value as? BalancePointResponse)
      XCTAssertNoDifference(sut2.value as! BalancePointResponse, expected)
    }
  }

}
