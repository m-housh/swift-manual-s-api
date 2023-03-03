import Models
import XCTest

final class ModelTests: XCTestCase {
  
  func test_embeddable_keys() {
    for key in Template.EmbeddableKey.allCases {
      let pathKey = key.pathKey
      switch key {
      case .boiler:
        XCTAssertEqual(pathKey, .boiler)
      case .electric:
        XCTAssertEqual(pathKey, .electric)
      case .furnace:
        XCTAssertEqual(pathKey, .furnace)
      case .heatPump:
        XCTAssertEqual(pathKey, .heatPump)
      case .noInterpolation:
        XCTAssertEqual(pathKey, .noInterpolation)
      case .oneWayIndoor:
        XCTAssertEqual(pathKey, .oneWayIndoor)
      case .oneWayOutdoor:
        XCTAssertEqual(pathKey, .oneWayOutdoor)
      case .twoWay:
        XCTAssertEqual(pathKey, .twoWay)
      }
    }
  }
}
