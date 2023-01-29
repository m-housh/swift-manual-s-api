import XCTest
import Models
import SiteHandlerLive
import SiteRouteValidationsLive
import CustomDump

final class BalancePointTests: XCTestCase {
  
  let client = SiteHandler.live
  
  func test_thermalBalancePoint() async throws {
    let request = ServerRoute.Api.Route.balancePoint(.thermal(.init(designTemperature: 5, heatLoss: 49_667, capacity: .mock)))
    let sut = try await client.api.balancePoint(.thermal(.init(designTemperature: 5, heatLoss: 49_667, capacity: .mock)))
    let expected = BalancePointResponse(balancePoint: 38.5)
    
    XCTAssertNoDifference(sut, expected)
    
    let sut2 = try await client.respond(.api(.init(isDebug: true, route: request)))
    XCTAssertNotNil(sut2.value as? BalancePointResponse)
    XCTAssertNoDifference(sut2.value as? BalancePointResponse, expected)
    
  }
  
  func test_thermalBalancePoint_validations() async throws {
    await XCTAssertThrowsError(
      try await ServerRoute.Api.Route.BalancePointRequest.Thermal(
        designTemperature: 0,
        heatLoss: 0,
        capacity: .mock
      )
      .validate()
    )
    
    await XCTAssertThrowsError(
      try await ServerRoute.Api.Route.BalancePointRequest.Thermal(
        designTemperature: 0,
        heatLoss: 12345,
        capacity: .init(at47: 1, at17: 2)
      )
      .validate()
    )
  }
}
