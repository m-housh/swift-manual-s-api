import XCTest
import Models
import UtilsClientLive

final class RequiredKWTests: XCTestCase {
  
  let client = UtilsClient.live
  
  func test_requiredKW() async throws {
    let sut = try await client.requiredKW(.init(houseLoad: .mock, capacityAtDesign: 0))
    XCTAssertEqual(sut, .init(requiredKW: 14.55))
    
    let sut2 = try await client.requiredKW(.init(houseLoad: .mock, capacityAtDesign: 11_300))
    XCTAssertEqual(sut2.requiredKW, 11.24)
    
  }
}
