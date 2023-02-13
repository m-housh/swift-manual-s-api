import XCTest
import Dependencies
import Models
import ApiRouteMiddlewareLive
import FirstPartyMocks

@MainActor
final class DeratingClientTests: XCTestCase {
  
  func testFurnaceDerating() async throws {
    try await withLiveSiteHandler {
      
      @Dependency(\.apiMiddleware) var client
      
      var elevation = 1
      var iteration = 0
      let expected = [
        1.0,
        0.96,
        0.92,
        0.88,
        0.84,
        0.8,
        0.76,
        0.72,
        0.68,
        0.64,
        0.6,
        0.56,
        0.52
      ]
      
      while iteration < expected.count {
        let request1 = ServerRoute.Api(
          isDebug: true,
          route: .derating(.init(elevation: elevation, systemType: .furnaceOnly))
        )
        let request2 = ServerRoute.Api(
          isDebug: true,
          route: .derating(.init(elevation: elevation, systemType: .boilerOnly))
        )
        let sut = try await client.respond(request1).value as! AdjustmentMultiplier
        let sut2 = try await client.respond(request2).value as! AdjustmentMultiplier
        XCTAssertEqual(sut, .heating(multiplier: expected[iteration]))
        XCTAssertEqual(sut2, .heating(multiplier: expected[iteration]))
        iteration += 1
        elevation += 1000
      }
      
      let belowZeroRequest = ServerRoute.Api(
        isDebug: true,
        route: .derating(.init(elevation: -1, systemType: .furnaceOnly))
      )
      let belowZero = try await client.respond(belowZeroRequest).value as! AdjustmentMultiplier
      XCTAssertEqual(belowZero, .heating(multiplier: 1))
    }
  }
  
  func testTotalWetDerating() async throws {
    try await withLiveSiteHandler {
      
      @Dependency(\.apiMiddleware) var client
      
      var elevation = 1
      var iteration = 0
      let expectedTotal = [
        1.0,
        0.99,
        0.98,
        0.98,
        0.97,
        0.96,
        0.95,
        0.94,
        0.94,
        0.93,
        0.92,
        0.91,
        0.9
      ]
      let expectedSensible = [
        1.0,
        0.97,
        0.94,
        0.91,
        0.88,
        0.85,
        0.82,
        0.8,
        0.77,
        0.74,
        0.71,
        0.68,
        0.65
      ]
      let expectedHeating = [
        1.0,
        0.98,
        0.97,
        0.95,
        0.94,
        0.92,
        0.9,
        0.89,
        0.87,
        0.86,
        0.84,
        0.82,
        0.81
      ]
      
      // Make sure that the counts are the same.
      guard expectedTotal.count == expectedSensible.count,
              expectedTotal.count == expectedHeating.count
      else {
        XCTFail()
        return
      }
      
      while iteration < expectedTotal.count {
        let request = ServerRoute.Api(
          isDebug: true,
          route: .derating(.init(elevation: elevation, systemType: .default))
        )
        let sut = try await client.respond(request).value as! AdjustmentMultiplier
        XCTAssertEqual(
          sut,
          .airToAir(
            total: expectedTotal[iteration],
            sensible: expectedSensible[iteration],
            heating: expectedHeating[iteration]
          )
        )
        iteration += 1
        elevation += 1000
      }
      
      let request2 = ServerRoute.Api(
        isDebug: true,
        route: .derating(.init(elevation: -1, systemType: .default))
      )
      
      let belowZero = try await client.respond(request2).value as! AdjustmentMultiplier
      XCTAssertEqual(belowZero, .airToAir(total: 1, sensible: 1, heating: 1))
    }
  }
  
  func test_anyEncodable_response() async throws {
    try await withLiveSiteHandler {
      @Dependency(\.apiMiddleware) var client
      
      let request = ServerRoute.Api(
        isDebug: true,
        route: .derating(.init(elevation: 0, systemType: .default))
      )
      let expected = AdjustmentMultiplier.airToAir(total: 1, sensible: 1, heating: 1)
      
      let sut = try await client.respond(request).value as! AdjustmentMultiplier
      XCTAssertEqual(sut, expected)
    }
  }
  
}
