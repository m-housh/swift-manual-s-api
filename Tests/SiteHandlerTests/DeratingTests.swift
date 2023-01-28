import XCTest
import Models
import SiteHandlerLive

final class DeratingClientTests: XCTestCase {
  
  let client = SiteHandler.live
  
  func testFurnaceDerating() async throws {
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
      let sut = try await client.api.derating(.init(elevation: elevation, systemType: .furnaceOnly))
      let sut2 = try await client.api.derating(.init(elevation: elevation, systemType: .boilerOnly))
      XCTAssertEqual(sut, .heating(expected[iteration]))
      XCTAssertEqual(sut2, .heating(expected[iteration]))
      iteration += 1
      elevation += 1000
    }
    
    let belowZero = try await client.api.derating(.init(elevation: -1, systemType: .furnaceOnly))
    XCTAssertEqual(belowZero, .heating(1))
  }
  
  func testTotalWetDerating() async throws {
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
    
    guard expectedTotal.count == expectedSensible.count, expectedTotal.count == expectedHeating.count else {
      XCTFail()
      return
    }

    while iteration < expectedTotal.count {
      let sut = try await client.api.derating(.init(elevation: elevation, systemType: .default))
      XCTAssertEqual(sut, .airToAir(total: expectedTotal[iteration], sensible: expectedSensible[iteration], heating: expectedHeating[iteration]))
      iteration += 1
      elevation += 1000
    }
    
    let belowZero = try await client.api.derating(.init(elevation: -1, systemType: .default))
    XCTAssertEqual(belowZero, .airToAir(total: 1, sensible: 1, heating: 1))

  }

}
