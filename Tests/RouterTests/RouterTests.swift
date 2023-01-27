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
  
//  func test_() throws {
//    let req = try _apiRouter.request(for: .interpolate(.cooling(.noInterpolation(.init(
//      capacity: .init(
//        cfm: 800,
//        indoorTemperature: 75,
//        indoorWetBulb: 63,
//        outdoorTemperature: 90,
//        capacity: .init(total: 12345, sensible: 12345)
//      ),
//      designInfo: .mock,
//      houseLoad: .mock,
//      manufacturerAdjustments: nil,
//      systemType: .airToAir(type: .heatPump, compressor: .variableSpeed, climate: .mildWinterOrLatentLoad)))))
//    )
//
//    print(String(data: req.httpBody!, encoding: .utf8)!)
//    XCTFail()
//
//  }
  
  func test_noInterpolationRoute() throws {
    let json = """
    {
      "capacity" : {
        "cfm" : 800,
        "indoorTemperature" : 75,
        "indoorWetBulb" : 63,
        "outdoorTemperature" : 90,
        "capacity" : {
          "total" : 12345,
          "sensible" : 12345
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
      },
      "houseLoad" : {
        "heating" : 49667,
        "cooling" : {
          "total" : 17872,
          "sensible" : 13894
        }
      },
      "systemType" : {
        "airToAir" : {
          "type" : "heatPump",
          "compressor" : "variableSpeed",
          "climate" : "mildWinterOrLatentLoad"
        }
      }
    }
    """
    
    var request = URLRequest(url: URL(string: "/interpolate/cooling/noInterpolation")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)
    
    let route = try _apiRouter.match(request: request)
    XCTAssertNoDifference(
      route,
      .interpolate(.cooling(.noInterpolation(.init(
        capacity: .init(
          cfm: 800,
          indoorTemperature: 75,
          indoorWetBulb: 63,
          outdoorTemperature: 90,
          capacity: .init(total: 12345, sensible: 12345)
        ),
        designInfo: .init(),
        houseLoad: .init(heating: 49_667, cooling: .init(total: 17_872, sensible: 13_894)),
        manufacturerAdjustments: nil,
        systemType: .airToAir(type: .heatPump, compressor: .variableSpeed, climate: .mildWinterOrLatentLoad)
      ))))
    )
  }
  
  func test_oneWayIndoor() throws {
    let json = """
    {
      "aboveDesign" : {
        "capacity" : {
          "sensible" : 1,
          "total" : 1
        },
        "cfm" : 800,
        "indoorTemperature" : 75,
        "indoorWetBulb" : 63,
        "outdoorTemperature" : 95
      },
      "belowDesign" : {
        "capacity" : {
          "sensible" : 1,
          "total" : 1
        },
        "cfm" : 800,
        "indoorTemperature" : 75,
        "indoorWetBulb" : 63,
        "outdoorTemperature" : 85
      },
      "designInfo" : {
        "elevation" : 0,
        "summer" : {
          "indoorHumidity" : 50,
          "indoorTemperature" : 75,
          "outdoorTemperature" : 90
        },
        "winter" : {
          "outdoorTemperature" : 5
        }
      },
      "houseLoad" : {
        "cooling" : {
          "sensible" : 13894,
          "total" : 17872
        },
        "heating" : 49667
      },
      "systemType" : {
        "airToAir" : {
          "climate" : "mildWinterOrLatentLoad",
          "compressor" : "variableSpeed",
          "type" : "heatPump"
        }
      }
    }
    """
    
    var request = URLRequest(url: URL(string: "/interpolate/cooling/oneWayIndoor")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)
    
    let route = try _apiRouter.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .interpolate(.cooling(.oneWayIndoor(.init(
        aboveDesign: .init(
          cfm: 800,
          indoorTemperature: 75,
          indoorWetBulb: 63,
          outdoorTemperature: 95,
          capacity: .init(total: 1, sensible: 1)
        ),
        belowDesign: .init(
          cfm: 800,
          indoorTemperature: 75,
          indoorWetBulb: 63,
          outdoorTemperature: 85,
          capacity: .init(total: 1, sensible: 1)
        ),
        designInfo: .mock,
        houseLoad: .mock,
        systemType: .default
      ))))
    )
  }
  
  func test_oneWayOutdoor() throws {
    let json = """
    {
      "aboveDesign" : {
        "capacity" : {
          "sensible" : 1,
          "total" : 1
        },
        "cfm" : 800,
        "indoorTemperature" : 75,
        "indoorWetBulb" : 63,
        "outdoorTemperature" : 95
      },
      "belowDesign" : {
        "capacity" : {
          "sensible" : 1,
          "total" : 1
        },
        "cfm" : 800,
        "indoorTemperature" : 75,
        "indoorWetBulb" : 63,
        "outdoorTemperature" : 85
      },
      "designInfo" : {
        "elevation" : 0,
        "summer" : {
          "indoorHumidity" : 50,
          "indoorTemperature" : 75,
          "outdoorTemperature" : 90
        },
        "winter" : {
          "outdoorTemperature" : 5
        }
      },
      "houseLoad" : {
        "cooling" : {
          "sensible" : 13894,
          "total" : 17872
        },
        "heating" : 49667
      },
      "systemType" : {
        "airToAir" : {
          "climate" : "mildWinterOrLatentLoad",
          "compressor" : "variableSpeed",
          "type" : "heatPump"
        }
      }
    }
    """
    
    var request = URLRequest(url: URL(string: "/interpolate/cooling/oneWayOutdoor")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)
    
    let route = try _apiRouter.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .interpolate(.cooling(.oneWayOutdoor(.init(
        aboveDesign: .init(
          cfm: 800,
          indoorTemperature: 75,
          indoorWetBulb: 63,
          outdoorTemperature: 95,
          capacity: .init(total: 1, sensible: 1)
        ),
        belowDesign: .init(
          cfm: 800,
          indoorTemperature: 75,
          indoorWetBulb: 63,
          outdoorTemperature: 85,
          capacity: .init(total: 1, sensible: 1)
        ),
        designInfo: .mock,
        houseLoad: .mock,
        systemType: .default
      ))))
    )

  }
  
  func test_twoWay() throws {
    let json = """
    {
      "aboveDesign" : {
        "above" : {
          "capacity" : {
            "sensible" : 15937,
            "total" : 24828
          },
          "cfm" : 800,
          "indoorTemperature" : 75,
          "indoorWetBulb" : 67,
          "outdoorTemperature" : 95
        },
        "below" : {
          "capacity" : {
            "sensible" : 19078,
            "total" : 23046
          },
          "cfm" : 800,
          "indoorTemperature" : 75,
          "indoorWetBulb" : 62,
          "outdoorTemperature" : 95
        }
      },
      "belowDesign" : {
        "above" : {
          "capacity" : {
            "sensible" : 16330,
            "total" : 25986
          },
          "cfm" : 800,
          "indoorTemperature" : 75,
          "indoorWetBulb" : 67,
          "outdoorTemperature" : 85
        },
        "below" : {
          "capacity" : {
            "sensible" : 19605,
            "total" : 24029
          },
          "cfm" : 800,
          "indoorTemperature" : 75,
          "indoorWetBulb" : 62,
          "outdoorTemperature" : 85
        }
      },
      "designInfo" : {
        "elevation" : 0,
        "summer" : {
          "indoorHumidity" : 50,
          "indoorTemperature" : 75,
          "outdoorTemperature" : 90
        },
        "winter" : {
          "outdoorTemperature" : 5
        }
      },
      "houseLoad" : {
        "cooling" : {
          "sensible" : 13894,
          "total" : 17872
        },
        "heating" : 49667
      },
      "systemType" : {
        "airToAir" : {
          "climate" : "mildWinterOrLatentLoad",
          "compressor" : "variableSpeed",
          "type" : "heatPump"
        }
      }
    }
    """
    
    var request = URLRequest(url: URL(string: "/interpolate/cooling/twoWay")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)
    
    let route = try _apiRouter.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .interpolate(.cooling(.twoWay(.init(
        aboveDesign: .init(
          above: .init(
            cfm: 800,
            indoorTemperature: 75,
            indoorWetBulb: 67,
            outdoorTemperature: 95,
            capacity: .init(total: 24_828, sensible: 15_937)
          ),
          below: .init(
            cfm: 800,
            indoorTemperature: 75,
            indoorWetBulb: 62,
            outdoorTemperature: 95,
            capacity: .init(total: 23_046, sensible: 19_078)
          )
        ),
        belowDesign: .init(
          above: .init(
            cfm: 800,
            indoorTemperature: 75,
            indoorWetBulb: 67,
            outdoorTemperature: 85,
            capacity: .init(total: 25_986, sensible: 16_330)
          ),
          below: .init(
            cfm: 800,
            indoorTemperature: 75,
            indoorWetBulb: 62,
            outdoorTemperature: 85,
            capacity: .init(total: 24_029, sensible: 19_605)
          )
        ),
        designInfo: .mock,
        houseLoad: .mock,
        systemType: .default
      ))))
    )
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

