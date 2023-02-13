import XCTest
import URLRouting
import CustomDump
import Models
import FirstPartyMocks
import SiteRouter

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

// TODO: Add heating interpolation routes.
final class RouterTests: XCTestCase {
  
  let router = SiteRouterKey.testValue
  
  func test_balance_point() throws {
    let json = """
    {
      "designTemperature": 5,
      "heatLoss": 49667,
      "capacity": {
        "at47": 24600,
        "at17": 15100
      }
    }
    """
    var request = URLRequest(url: URL(string: "/api/balancePoint/thermal")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .api(.init(
        isDebug: false,
        route: .balancePoint(.thermal(.init(
          designTemperature: 5,
          heatLoss: 49_667,
          capacity: .mock
        )))))
    )
  }
  
  func test_requiredkw() throws {
    let json = """
    {
      "capacityAtDesign": 0,
      "heatLoss": 12345
    }
    """
    var request = URLRequest(url: URL(string: "/api/requiredKW")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .api(
        .init(
          isDebug: false,
          route: .requiredKW(.init(capacityAtDesign: 0, heatLoss: 12345))
        )
      )
    )
  }
  
  func test_derating() throws {
    let json = """
    {
      "elevation": 0,
      "systemType": {
        "airToAir" : {
          "type" : "heatPump",
          "compressor" : "variableSpeed",
          "climate" : "mildWinterOrLatentLoad"
        }
      }
    }
    """
    
    var request = URLRequest(url: URL(string: "/api/derating")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .api(
        .init(
          isDebug: false,
          route: .derating(
            .init(
              elevation: 0,
              systemType: .airToAir(type: .heatPump, compressor: .variableSpeed, climate: .mildWinterOrLatentLoad)
            )
          )
        )
      )
    )
  }
  
  func test_sizingLimits() throws {
    let json = """
    {
      "houseLoad": {
        "heating" : 49667,
        "cooling" : {
          "total" : 17872,
          "sensible" : 13894
        }
      },
      "systemType": {
        "airToAir" : {
          "type" : "heatPump",
          "compressor" : "variableSpeed",
          "climate" : "mildWinterOrLatentLoad"
        }
      }
    }
    """
    
    var request = URLRequest(url: URL(string: "/api/sizingLimits")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .api(
        .init(
          isDebug: false,
          route: .sizingLimits(.init(systemType: .mock, houseLoad: .mock))
        )
      )
    )
  }
  
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
    
    var request = URLRequest(url: URL(string: "/api/interpolate/cooling/noInterpolation")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)
    
    let route = try router.match(request: request)
    XCTAssertNoDifference(
      route,
      .api(
        .init(
          isDebug: false,
          route: .interpolate(.cooling(.noInterpolation(.init(
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
          )))))
      )
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
    
    var request = URLRequest(url: URL(string: "/api/interpolate/cooling/oneWayIndoor")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .api(
        .init(
          isDebug: false,
          route: .interpolate(.cooling(.oneWayIndoor(.init(
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
          )))))
      )
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
    
    var request = URLRequest(url: URL(string: "/api/interpolate/cooling/oneWayOutdoor")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .api(
        .init(
          isDebug: false,
          route: .interpolate(.cooling(.oneWayOutdoor(.init(
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
          )))))
      )
    )
    
  }
  
  func test_twoWay() throws {
    let json = """
    {
      "aboveDesign" : {
        "aboveWetBulb" : {
          "capacity" : {
            "sensible" : 15937,
            "total" : 24828
          },
          "cfm" : 800,
          "indoorTemperature" : 75,
          "indoorWetBulb" : 67,
          "outdoorTemperature" : 95
        },
        "belowWetBulb" : {
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
        "aboveWetBulb" : {
          "capacity" : {
            "sensible" : 16330,
            "total" : 25986
          },
          "cfm" : 800,
          "indoorTemperature" : 75,
          "indoorWetBulb" : 67,
          "outdoorTemperature" : 85
        },
        "belowWetBulb" : {
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
    
    var request = URLRequest(url: URL(string: "/api/interpolate/cooling/twoWay")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .api(
        .init(
          isDebug: false,
          route: .interpolate(.cooling(.twoWay(.init(
            aboveDesign: .init(
              aboveWetBulb: .init(
                cfm: 800,
                indoorTemperature: 75,
                indoorWetBulb: 67,
                outdoorTemperature: 95,
                capacity: .init(total: 24_828, sensible: 15_937)
              ),
              belowWetBulb: .init(
                cfm: 800,
                indoorTemperature: 75,
                indoorWetBulb: 62,
                outdoorTemperature: 95,
                capacity: .init(total: 23_046, sensible: 19_078)
              )
            ),
            belowDesign: .init(
              aboveWetBulb: .init(
                cfm: 800,
                indoorTemperature: 75,
                indoorWetBulb: 67,
                outdoorTemperature: 85,
                capacity: .init(total: 25_986, sensible: 16_330)
              ),
              belowWetBulb: .init(
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
          )))))
      )
    )
  }
  
  func test_boiler() throws {
    let json = """
    {
      "altitudeDeratings": {
        "heating": {
          "multiplier": 1.0
        }
      },
      "houseLoad": {
        "cooling": {
          "total": 17872,
          "sensible": 13894
        },
        "heating": 49667,
      },
      "input": 100000,
      "afue": 96.5
    }
    """
    var request = URLRequest(url: URL(string: "/api/interpolate/heating/boiler")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)
    
    let route = try router.match(request: request)
   
    XCTAssertNoDifference(
      route,
      .api(.init(
        isDebug: false,
        route: .interpolate(.heating(.boiler(.init(
          altitudeDeratings: .heating(multiplier: 1),
          houseLoad: .mock,
          input: 100_000,
          afue: 96.5
        ))))
      ))
    )
  }
  
  func test_furnace() throws {
    let json = """
    {
      "altitudeDeratings": {
        "airToAir": {
          "total": 1.0,
          "sensible": 1.0,
          "heating": 1.0
        }
      },
      "houseLoad": {
        "cooling": {
          "total": 17872,
          "sensible": 13894
        },
        "heating": 49667,
      },
      "input": 100000,
      "afue": 96.5
    }
    """
    var request = URLRequest(url: URL(string: "/api/interpolate/heating/furnace")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)
    
    let route = try router.match(request: request)
   
    XCTAssertNoDifference(
      route,
      .api(.init(
        isDebug: false,
        route: .interpolate(.heating(.furnace(.init(
          altitudeDeratings: .airToAir(total: 1, sensible: 1, heating: 1),
          houseLoad: .mock,
          input: 100_000,
          afue: 96.5
        ))))
      ))
    )
  }
  
  func test_electric() throws {

    let json = """
    {
      "altitudeDeratings": {
        "heating": {
          "multiplier": 1.0
        }
      },
      "heatPumpCapacity": 12000,
      "houseLoad": {
        "cooling": {
          "total": 17872,
          "sensible": 13894
        },
        "heating": 49667
      },
      "inputKW": 12.5
    }
    """
    var request = URLRequest(url: URL(string: "/api/interpolate/heating/electric")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .api(.init(
        isDebug: false,
        route: .interpolate(.heating(.electric(.init(
          altitudeDeratings: .heating(multiplier: 1),
          heatPumpCapacity: 12_000,
          houseLoad: .mock,
          inputKW: 12.5
        ))))
      ))
    )
    
  }
  
  func test_heat_pump() throws {
    let json = """
    {
      "altitudeDeratings": {
        "airToAir": {
          "total": 1.0,
          "sensible": 1.0,
          "heating": 1.0
        }
      },
      "capacity": {
        "at47": 24600,
        "at17": 15100
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
      "houseLoad": {
        "cooling": {
          "total": 17872,
          "sensible": 13894
        },
        "heating": 49667
      }
    }
    """
    var request = URLRequest(url: URL(string: "/api/interpolate/heating/heatPump")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)
    
    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .api(.init(
        isDebug: false,
        route: .interpolate(.heating(.heatPump(.init(
          altitudeDeratings: .airToAir(total: 1, sensible: 1, heating: 1),
          capacity: .mock,
          designInfo: .mock,
          houseLoad: .mock
        ))))
      ))
    )
    
  }
  
}

