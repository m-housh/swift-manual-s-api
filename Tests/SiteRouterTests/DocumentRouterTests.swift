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
  
  let router = SiteRouter.testValue
  
  func test_requiredkw() throws {
    var request = URLRequest(url: URL(string: "/documentation/api/requiredKW")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .documentation(.route(.requiredKW))
    )
  }
  
  func test_derating() throws {

    var request = URLRequest(url: URL(string: "/documentation/api/derating")!)
    request.httpMethod = "GET"

    let route = try router.match(request: request)

    XCTAssertNoDifference(
      route,
      .documentation(.route(.derating))
    )
  }
  
  func test_sizingLimits() throws {
   
    var request = URLRequest(url: URL(string: "/documentation/api/sizingLimits")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .documentation(.route(.sizingLimits))
    )
  }
  
  func test_noInterpolationRoute() throws {
   
    var request = URLRequest(url: URL(string: "/documentation/api/interpolate/cooling/noInterpolation")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    XCTAssertNoDifference(
      route,
      .documentation(.route(.interpolate(.cooling(.noInterpolation))))
    )
  }
  
  func test_oneWayIndoor() throws {
   
    var request = URLRequest(url: URL(string: "/documentation/api/interpolate/cooling/oneWayIndoor")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .documentation(.route(.interpolate(.cooling(.oneWayIndoor))))
    )
  }
  
  func test_oneWayOutdoor() throws {
   
    var request = URLRequest(url: URL(string: "/documentation/api/interpolate/cooling/oneWayOutdoor")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .documentation(.route(.interpolate(.cooling(.oneWayOutdoor))))
    )
    
  }
  
  func test_twoWay() throws {
   
    var request = URLRequest(url: URL(string: "/documentation/api/interpolate/cooling/twoWay")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .documentation(.route(.interpolate(.cooling(.twoWay))))
    )
  }
  
  func test_boiler() throws {
   
    var request = URLRequest(url: URL(string: "/documentation/api/interpolate/heating/boiler")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .documentation(.route(.interpolate(.heating(.boiler))))
    )
  }
  
  func test_furnace() throws {
    
    var request = URLRequest(url: URL(string: "/documentation/api/interpolate/heating/furnace")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .documentation(.route(.interpolate(.heating(.furnace))))
    )
  }
  
  func test_electric() throws {
    
    var request = URLRequest(url: URL(string: "/documentation/api/interpolate/heating/electric")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .documentation(.route(.interpolate(.heating(.electric))))
    )
  }
  
    func test_heatPump() throws {
    
    var request = URLRequest(url: URL(string: "/documentation/api/interpolate/heating/heatPump")!)
    request.httpMethod = "GET"
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .documentation(.route(.interpolate(.heating(.heatPump))))
    )
  }
}

