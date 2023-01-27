import XCTest
import UtilsClientLive

final class BalancePointTests: XCTestCase {
  
  let client = UtilsClient.live
  
  func test_thermalBalancePoint() async throws {
    let sut = try await client.balancePoint(.thermal(.init(heatLoss: 49_667, heatPumpCapacity: .mock, winterDesignTemperature: 5)))
    XCTAssertEqual(sut.balancePoint, 38.5)
  }
}
