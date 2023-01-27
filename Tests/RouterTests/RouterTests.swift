import XCTest
import URLRouting
import ManualSClient
import CustomDump
import Models
@testable import Router

final class RouterTests: XCTestCase {
  
  func test_requiredkw() throws {
    let json = """
    {
      "capacityAtDesign": 0,
      "heatLoss": 12345
    }
    """
    var request = URLRequest(url: URL(string: "/requiredKW")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)
    
    let route = try _apiRouter.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .requiredKW(.init(capacityAtDesign: 0, heatLoss: 12345))
    )
  }
  
  func test_NoInterpolation() throws {
    let x = try _apiRouter.request(for: .interpolate(.cooling(.noInterpolation(.init(capacity: .init(cfm: 800, indoorTemperature: 75, indoorWetBulb: 63, outdoorTemperature: 90, capacity: .init(total: 12345, sensible: 12345)), designInfo: .mock, houseLoad: .mock, manufacturerAdjustments: nil, systemType: .default)))))
    
    print(x.url!)
    print(String(data: x.httpBody!, encoding: .utf8))
//    XCTFail()
    
  }
  
  func test_noInterpolationRoute() throws {
    let json = """
    {
      "houseLoad" : {
        "heating" : 49667,
        "cooling" : {
          "total" : 17872,
          "sensible" : 13894
        }
      },
      "capacity" : {
        "cfm" : 800,
        "indoorTemperature" : 75,
        "indoorWetBulb" : 63,
        "outdoorTemperature" : 90,
        "capacity" : {
          "total" : 12345,
          "sensible" : 12344
        }
      },
      "systemType" : {
        "airToAir" : {
          "type" : {
            "heatPump" : {

            }
          },
          "compressor" : {
            "variableSpeed" : {

            }
          },
          "climate" : {
            "mildWinterOrLatentLoad" : {

            }
          }
        }
      },
      "designInfo" : {
        "summer" : {
          "outdoorTemperature" : 90,
          "indoorTemperature" : 75,
          "indoorHumidity" : 50
        },
        "winter" : {
          "outdoorTemperature" : 5
        },
        "elevation" : 0
      }
    }
    """
    
    var request = URLRequest(url: URL(string: "noInterpolation")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)
    
//    let r = ServerRoute.Api.Route.InterpolationRequest.Cooling.NoInterpolationRequest(
//      capacity: .init(
//        cfm: 800,
//        indoorTemperature: 75,
//        indoorWetBulb: 63,
//        outdoorTemperature: 90,
//        capacity: .init(total: 12345, sensible: 12344)
//      ),
//      designInfo: .mock,
//      houseLoad: .mock,
//      manufacturerAdjustments: nil,
//      systemType: .mock
//    )
//
//    let encoder = JSONEncoder()
//    encoder.outputFormatting = .prettyPrinted
//
//    let data = try encoder.encode(r)
//    print(String(data: data, encoding: .utf8)!)
//    XCTFail()
    
//    let _ = try JSONDecoder().decode(ServerRoute.Api.Route.InterpolationRequest.Cooling.NoInterpolationRequest.self, from: Data(json.utf8))
    let route = try _coolingInterpolationRouter.match(request: request)
//    XCTAssertNoDifference(route, .noInterpolation(.init(capacity: <#T##CoolingCapacityEnvelope#>, designInfo: <#T##DesignInfo#>, houseLoad: <#T##HouseLoad#>, manufacturerAdjustments: <#T##AdjustmentMultiplier?#>, systemType: <#T##SystemType#>)))
//
  }
  
//  func test_apiRouter() throws {
//    var req = URLRequestData(string: "/api/required-kw")!
//    req.method = "POST"
//    req.body = try? JSONEncoder().encode(ManualSClient.RequiredKWRequest.init(houseLoad: .mock))
//    
//    
//    let sut = try manualSRouter.parse(req)
//    XCTAssertEqual(sut, .api(.requiredKW(.init(houseLoad: .mock))))
//    
//    req.method = "GET"
//    XCTAssertThrowsError(try manualSRouter.parse(req))
//  }
}

