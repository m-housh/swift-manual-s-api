import XCTest
import URLRouting
import CustomDump
import Models
import FirstPartyMocks
import SiteRouter

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif


final class DocumentRouterTests: XCTestCase {
  
  let router = SiteRouterKey.testValue
  
  func test_requiredkw() throws {
    var request = URLRequest(url: URL(string: "/documentation/api/v1/requiredKW")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .documentation(.api(.requiredKW))
    )
  }
  
  func test_derating() throws {

    var request = URLRequest(url: URL(string: "/documentation/api/v1/derating")!)
    request.httpMethod = "GET"

    let route = try router.match(request: request)

    XCTAssertNoDifference(
      route,
      .documentation(.api(.derating))
    )
  }
  
  func test_sizingLimits() throws {
   
    var request = URLRequest(url: URL(string: "/documentation/api/v1/sizingLimits")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .documentation(.api(.sizingLimits))
    )
  }
  
  func test_noInterpolationRoute() throws {
   
    var request = URLRequest(url: URL(string: "/documentation/api/v1/interpolate/cooling/noInterpolation")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    XCTAssertNoDifference(
      route,
      .documentation(.api(.interpolate(.cooling(.noInterpolation))))
    )
  }
  
  func test_oneWayIndoor() throws {
   
    var request = URLRequest(url: URL(string: "/documentation/api/v1/interpolate/cooling/oneWayIndoor")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .documentation(.api(.interpolate(.cooling(.oneWayIndoor))))
    )
  }
  
  func test_oneWayOutdoor() throws {
   
    var request = URLRequest(url: URL(string: "/documentation/api/v1/interpolate/cooling/oneWayOutdoor")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .documentation(.api(.interpolate(.cooling(.oneWayOutdoor))))
    )
    
  }
  
  func test_twoWay() throws {
   
    var request = URLRequest(url: URL(string: "/documentation/api/v1/interpolate/cooling/twoWay")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .documentation(.api(.interpolate(.cooling(.twoWay))))
    )
  }
  
  func test_boiler() throws {
   
    var request = URLRequest(url: URL(string: "/documentation/api/v1/interpolate/heating/boiler")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .documentation(.api(.interpolate(.heating(.boiler))))
    )
  }
  
  func test_furnace() throws {
    
    var request = URLRequest(url: URL(string: "/documentation/api/v1/interpolate/heating/furnace")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .documentation(.api(.interpolate(.heating(.furnace))))
    )
  }
  
  func test_electric() throws {
    
    var request = URLRequest(url: URL(string: "/documentation/api/v1/interpolate/heating/electric")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .documentation(.api(.interpolate(.heating(.electric))))
    )
  }
  
    func test_heatPump() throws {
    
    var request = URLRequest(url: URL(string: "/documentation/api/v1/interpolate/heating/heatPump")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .documentation(.api(.interpolate(.heating(.heatPump))))
    )
  }
  
  func test_interpolate_home() throws {
    
    var request = URLRequest(url: URL(string: "/documentation/api/v1/interpolate")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .documentation(.api(.interpolate(.home)))
    )
  }
}

