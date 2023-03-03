import CustomDump
import Dependencies
import JsonDependency
import Models
import FirstPartyMocks
import SiteRouter
import URLRouting
import XCTest

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

// TODO: Add heating interpolation routes.
final class RouterTests: XCTestCase {
  
  override func invokeTest() {
    let router = withDependencies {
      $0.json = .liveValue
    } operation: {
      SiteRouter()
    }
    
    withDependencies {
      $0.json = .liveValue
      $0.siteRouter = router.eraseToAnyParserPrinter()
    } operation: {
      super.invokeTest()
    }
  }
  
  func test_balance_point() throws {
    @Dependency(\.siteRouter) var router
    
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
    var request = URLRequest(url: URL(string: "/api/v1/balancePoint/thermal")!)
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
    @Dependency(\.siteRouter) var router
    let json = """
    {
      "capacityAtDesign": 0,
      "heatLoss": 12345
    }
    """
    var request = URLRequest(url: URL(string: "/api/v1/requiredKW")!)
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
    @Dependency(\.siteRouter) var router
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
    
    var request = URLRequest(url: URL(string: "/api/v1/derating")!)
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
    @Dependency(\.siteRouter) var router
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
    
    var request = URLRequest(url: URL(string: "/api/v1/sizingLimits")!)
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
    @Dependency(\.siteRouter) var router
    let json = """
    {
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
      },
      "route" : {
        "cooling" : {
          "noInterpolation" : {
            "capacity" : {
              "capacity" : {
                "sensible" : 16600,
                "total" : 22000
              },
              "cfm" : 800,
              "indoorTemperature" : 75,
              "indoorWetBulb" : 63,
              "outdoorTemperature" : 90
            }
          }
        }
      }
    }
    """
    
    var request = URLRequest(url: URL(string: "/api/v1/interpolate")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)
    
    let route = try router.match(request: request)
    XCTAssertNoDifference(
      route,
      .api(
        .init(
          isDebug: false,
          route: .interpolate(.init(
            designInfo: .init(),
            houseLoad: .init(heating: 49_667, cooling: .init(total: 17_872, sensible: 13_894)),
            route: .cooling(
              route: .noInterpolation(.init(
                capacity: .init(
                  cfm: 800,
                  indoorTemperature: 75,
                  indoorWetBulb: 63,
                  outdoorTemperature: 90,
                  capacity: .init(total: 22_000, sensible: 16_600)
                ),
                manufacturerAdjustments: nil
              ))
            )
          ))
        )
      )
    )
  }
  
  func test_oneWayIndoor() throws {
    @Dependency(\.siteRouter) var router
    let json = """
    {
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
      },
      "route" : {
        "cooling" : {
          "oneWayIndoor" : {
            "aboveDesign" : {
              "capacity" : {
                "sensible" : 15937,
                "total" : 24828
              },
              "cfm" : 800,
              "indoorTemperature" : 75,
              "indoorWetBulb" : 67,
              "outdoorTemperature" : 95
            },
            "belowDesign" : {
              "capacity" : {
                "sensible" : 19078,
                "total" : 23046
              },
              "cfm" : 800,
              "indoorTemperature" : 75,
              "indoorWetBulb" : 62,
              "outdoorTemperature" : 95
            },
            "manufacturerAdjustments" : {
              "airToAir" : {
                "heating" : 1,
                "sensible" : 0.94999999999999996,
                "total" : 0.97999999999999998
              }
            }
          }
        }
      }
    }
    """

    var request = URLRequest(url: URL(string: "/api/v1/interpolate")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)

    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .api(
        .init(
          isDebug: false,
          route: .interpolate(.init(
            designInfo: .mock,
            houseLoad: .mock,
            route: .cooling(
              route: .oneWayIndoor(.init(.init(
                aboveDesign: .init(
                  cfm: 800,
                  indoorTemperature: 75,
                  indoorWetBulb: 67,
                  outdoorTemperature: 95,
                  capacity: .init(total: 24_828, sensible: 15_937)
                ),
                belowDesign: .init(
                  cfm: 800,
                  indoorTemperature: 75,
                  indoorWetBulb: 62,
                  outdoorTemperature: 95,
                  capacity: .init(total: 23_046, sensible: 19_078)
                ),
                manufacturerAdjustments: .airToAir(
                  total: 0.98,
                  sensible: 0.95,
                  heating: 1
                )
              )))))
          )
        )
      )
    )
    }

  func test_oneWayOutdoor() throws {
    @Dependency(\.siteRouter) var router
    let json = """
    {
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
      },
      "route" : {
        "cooling" : {
          "oneWayOutdoor" : {
            "aboveDesign" : {
              "capacity" : {
                "sensible" : 16600,
                "total" : 22000
              },
              "cfm" : 800,
              "indoorTemperature" : 75,
              "indoorWetBulb" : 63,
              "outdoorTemperature" : 95
            },
            "belowDesign" : {
              "capacity" : {
                "sensible" : 17100,
                "total" : 23200
              },
              "cfm" : 800,
              "indoorTemperature" : 75,
              "indoorWetBulb" : 63,
              "outdoorTemperature" : 85
            },
            "manufacturerAdjustments" : {
              "airToAir" : {
                "heating" : 1,
                "sensible" : 0.94999999999999996,
                "total" : 0.97999999999999998
              }
            }
          }
        }
      }
    }
    """

    var request = URLRequest(url: URL(string: "/api/v1/interpolate")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)

    let route = try router.match(request: request)

    XCTAssertNoDifference(
      route,
      .api(
        .init(
          isDebug: false,
          route: .interpolate(.init(
            
            designInfo: .mock,
            houseLoad: .mock,
            route: .cooling(
              route: .oneWayOutdoor(.init(.init(
                aboveDesign: .init(
                  cfm: 800,
                  indoorTemperature: 75,
                  indoorWetBulb: 63,
                  outdoorTemperature: 95,
                  capacity: .init(total: 22_000, sensible: 16_600)
                ),
                belowDesign: .init(
                  cfm: 800,
                  indoorTemperature: 75,
                  indoorWetBulb: 63,
                  outdoorTemperature: 85,
                  capacity: .init(total: 23_200, sensible: 17_100)
                ),
                manufacturerAdjustments: .airToAir(total: 0.98, sensible: 0.95, heating: 1)
              )))))
          )
        )
      )
    )

  }

  func test_twoWay() throws {
    @Dependency(\.siteRouter) var router
    let json = """
    {
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
      },
      "route" : {
        "cooling" : {
          "twoWay" : {
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
            "manufacturerAdjustments" : {
              "airToAir" : {
                "heating" : 1,
                "sensible" : 1,
                "total" : 1
              }
            }
          }
        }
      }
    }
    """

    var request = URLRequest(url: URL(string: "/api/v1/interpolate")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)

    let route = try router.match(request: request)

    XCTAssertNoDifference(
      route,
      .api(
        .init(
          isDebug: false,
          route: .interpolate(.init(
            designInfo: .mock,
            houseLoad: .mock,
            route: .cooling(
              route: .twoWay(.init(
                aboveDesign: .init(.init(
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
                )),
                belowDesign: .init(.init(
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
                ))),
                manufacturerAdjustments: .airToAir(total: 1, sensible: 1, heating: 1)
              ))))
          )
        )
      )
    )
  }

  func test_boiler() throws {
    @Dependency(\.siteRouter) var router
    let json = """
    {
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
      },
      "systemType": {
        "heatingOnly": "boiler"
      },
      "route": {
        "heating": {
          "boiler": {
            "input": 100000,
            "afue": 96.5
          }
        }
      }
    }
    """
    var request = URLRequest(url: URL(string: "/api/v1/interpolate")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)

    let route = try router.match(request: request)

    XCTAssertNoDifference(
      route,
      .api(.init(
        isDebug: false,
        route: .interpolate(.single(.init(
          designInfo: .init(),
          houseLoad: .mock,
          systemType: .heatingOnly(.boiler),
          route: .heating(
            route: .boiler(.init(
              input: 100_000,
              afue: 96.5
            )))))
        ))
      )
    )
  }

  func test_furnace() throws {
    @Dependency(\.siteRouter) var router
    let json = """
    {
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
      },
      "systemType": {
        "heatingOnly": "furnace"
      },
      "route": {
        "heating": {
          "furnace": {
            "input": 100000,
            "afue": 96.5
          }
        }
      }
    }
    """
    var request = URLRequest(url: URL(string: "/api/v1/interpolate")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)

    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .api(.init(
        isDebug: false,
        route: .interpolate(.init(
          designInfo: .init(),
          houseLoad: .mock,
          systemType: .heatingOnly(.furnace),
          route: .heating(
            route: .furnace(.init(
              input: 100_000,
              afue: 96.5
            ))))
        ))
      )
    )
  }

  func test_electric() throws {

    @Dependency(\.siteRouter) var router
    
    let json = """
    {
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
      "route" : {
        "heating" : {
          "electric" : {
            "heatPumpCapacity" : 23200,
            "inputKW" : 15
          }
        }
      },
      "systemType" : {
        "heatingOnly" : "electric"
      }
    }
    """
    var request = URLRequest(url: URL(string: "/api/v1/interpolate")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)

    let route = try router.match(request: request)
    
    XCTAssertNoDifference(
      route,
      .api(.init(
        isDebug: false,
        route: .interpolate(.init(
          designInfo: .init(),
          houseLoad: .mock,
          systemType: .heatingOnly(.electric),
          route: .heating(
            route: .electric(.init(
              heatPumpCapacity: 23_200,
              inputKW: 15
            ))))
        ))
      )
    )
  }

  func test_heat_pump() throws {
    @Dependency(\.siteRouter) var router
    let json = """
    {
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
      "route" : {
        "heating" : {
          "heatPump" : {
            "capacity" : {
              "at17" : 15100,
              "at47" : 24600
            }
          }
        }
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
    var request = URLRequest(url: URL(string: "http://localhost:8080/api/v1/interpolate")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)

    let route = try router.match(request: request)

    XCTAssertNoDifference(
      route,
      .api(.init(
        isDebug: false,
        route: .interpolate(.init(
          designInfo: .init(),
          houseLoad: .mock,
          systemType: .default,
          route: .heating(
            route: .heatPump(.init(
            capacity: .mock
          ))))
        )
      ))
    )
  }
  
  func test_systems_interpolation() throws {
    @Dependency(\.siteRouter) var router
    let json = """
    {
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
      "projectInfo" : {
        "address" : "1234 Sesame Street",
        "city" : "Monroe",
        "name" : "Blob Esquire",
        "state" : "OH",
        "zipCode" : 45050
      },
      "systems" : [
        {
          "cooling" : {
            "noInterpolation" : {
              "capacity" : {
                "capacity" : {
                  "sensible" : 16600,
                  "total" : 22000
                },
                "cfm" : 800,
                "indoorTemperature" : 75,
                "indoorWetBulb" : 63,
                "outdoorTemperature" : 90
              },
              "manufacturerAdjustments" : {
                "airToAir" : {
                  "heating" : 1,
                  "sensible" : 1,
                  "total" : 1
                }
              }
            }
          },
          "heating" : [
            {
              "furnace" : {
                "afue" : 96.5,
                "input" : 60000
              }
            }
          ],
          "name" : "bronze",
          "systemId" : "bronze-id",
          "systemType" : {
            "airToAir" : {
              "climate" : "mildWinterOrLatentLoad",
              "compressor" : "singleSpeed",
              "type" : "airConditioner"
            }
          }
        },
        {
          "cooling" : {
            "oneWayIndoor" : {
              "aboveDesign" : {
                "capacity" : {
                  "sensible" : 15937,
                  "total" : 24828
                },
                "cfm" : 800,
                "indoorTemperature" : 75,
                "indoorWetBulb" : 67,
                "outdoorTemperature" : 95
              },
              "belowDesign" : {
                "capacity" : {
                  "sensible" : 19078,
                  "total" : 23046
                },
                "cfm" : 800,
                "indoorTemperature" : 75,
                "indoorWetBulb" : 62,
                "outdoorTemperature" : 95
              },
              "manufacturerAdjustments" : {
                "airToAir" : {
                  "heating" : 1,
                  "sensible" : 0.94999999999999996,
                  "total" : 0.97999999999999998
                }
              }
            }
          },
          "heating" : [
            {
              "heatPump" : {
                "capacity" : {
                  "at17" : 15100,
                  "at47" : 24600
                }
              }
            },
            {
              "furnace" : {
                "afue" : 96.5,
                "input" : 60000
              }
            }
          ],
          "name" : "silver",
          "systemId" : "silver-id",
          "systemType" : {
            "airToAir" : {
              "climate" : "mildWinterOrLatentLoad",
              "compressor" : "variableSpeed",
              "type" : "heatPump"
            }
          }
        },
        {
          "cooling" : {
            "twoWay" : {
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
              "manufacturerAdjustments" : {
                "airToAir" : {
                  "heating" : 1,
                  "sensible" : 1,
                  "total" : 1
                }
              }
            }
          },
          "heating" : [
            {
              "heatPump" : {
                "capacity" : {
                  "at17" : 15100,
                  "at47" : 24600
                }
              }
            },
            {
              "furnace" : {
                "afue" : 96.5,
                "input" : 60000
              }
            }
          ],
          "name" : "gold",
          "systemId" : "gold-id",
          "systemType" : {
            "airToAir" : {
              "climate" : "mildWinterOrLatentLoad",
              "compressor" : "variableSpeed",
              "type" : "heatPump"
            }
          }
        }
      ]
    }
    """
    var request = URLRequest(url: URL(string: "http://localhost:8080/api/v1/interpolate")!)
    request.httpMethod = "POST"
    request.httpBody = Data(json.utf8)

    let route = try router.match(request: request)

    XCTAssertNoDifference(
      route,
      .api(.init(
        isDebug: false,
        route: .interpolate(.project(.mock))
      ))
    )

  }
  
}

