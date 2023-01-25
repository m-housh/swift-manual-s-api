import XCTest
import ManualSClient
import ManualSClientLive
import Models

final class RequiredKWTests: XCTestCase {
  
  let client = ManualSClient.live
  
  func test_requiredKW() async throws {
    let sut = try await client.requiredKW(.init(houseLoad: .mock, capacityAtDesign: 0))
    XCTAssertEqual(sut, 14.55)
    
    let sut2 = try await client.requiredKW(houseLoad: .mock, capacityAtDesign: 11_300)
    XCTAssertEqual(sut2, 11.24)
    
  }
}
