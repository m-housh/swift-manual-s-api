import XCTest
import CustomDump
import Dependencies
import Models
import ApiRouteMiddlewareLive
import FirstPartyMocks

@MainActor
final class CoolingInterpolationTests: XCTestCase {
  
  func test_noInterpolation() async throws {
    try await withLiveSiteHandler {
      
      @Dependency(\.apiMiddleware) var client
      
      let request = ServerRoute.Api.Route.Interpolation.Cooling.NoInterpolation(
        capacity: .init(
          cfm: 800,
          indoorTemperature: 75,
          indoorWetBulb: 63,
          outdoorTemperature: 90,
          capacity: .init(total: 22_600, sensible: 16_850)
        ),
        designInfo: .init(),
        houseLoad: .init(heating: 49_667, cooling: .init(total: 17_872, sensible: 13_894)),
        manufacturerAdjustments: nil,
        systemType: .default
      )
      
      let serverRoute = ServerRoute.Api(
        isDebug: true,
        route: .interpolate(.cooling(.noInterpolation(request)))
      )
      
      let sut = try await client.respond(serverRoute).value as? InterpolationResponse
      print(sut!.result)
      XCTAssertNotNil(sut)
      XCTAssertNoDifference(
        sut,
        .init(result: .cooling(.init(
          result: .init(
            interpolatedCapacity: request.capacity.capacity,
            excessLatent: 886,
            finalCapacityAtDesign: .init(total: 22_600, sensible: 17_736),
            altitudeDerating: .airToAir(total: 1, sensible: 1, heating: 1),
            capacityAsPercentOfLoad: .init(total: 126.5, sensible: 127.7, latent: 122.3),
            sizingLimits: .init(oversizing: .cooling(total: 130), undersizing: .cooling())
          ))
        )))
    }
  }

  
  func test_oneWayOutdoor() async throws {
    try await withLiveSiteHandler {
      
      @Dependency(\.apiMiddleware) var client
      
      let route = ServerRoute.Api.Route.Interpolation.Cooling.OneWay(
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
        designInfo: .init(),
        houseLoad: .mock,
        systemType: .default
      )
      
      let request = ServerRoute.Api(isDebug: true, route: .interpolate(.cooling(.oneWayOutdoor(route))))
      
      let sut = try await client.respond(request).value as! InterpolationResponse
      XCTAssertEqual(
        sut,
        .init(result: .cooling(.init(
          result: .init(
            interpolatedCapacity: .init(total: 22_600, sensible: 16_850),
            excessLatent: 886,
            finalCapacityAtDesign: .init(total: 22_600, sensible: 17_736),
            altitudeDerating: .airToAir(total: 1, sensible: 1, heating: 1),
            capacityAsPercentOfLoad: .init(total: 126.5, sensible: 127.7, latent: 122.3),
            sizingLimits: .init(oversizing: .cooling(total: 130), undersizing: .cooling())
          )
        )))
      )
    }
  }
  
  func test_oneWayIndoor() async throws {
    try await withLiveSiteHandler {
      
      @Dependency(\.apiMiddleware) var client
      
      let request = ServerRoute.Api.Route.Interpolation.Cooling.OneWay(
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
        designInfo: .oneWayIndoor,
        houseLoad: .mock,
        systemType: .default
      )
      
      let apiRequest = ServerRoute.Api(isDebug: true, route: .interpolate(.cooling(.oneWayIndoor(request))))
      
      let sut = try await client.respond(apiRequest).value as! InterpolationResponse
      XCTAssertNoDifference(
        sut,
        .init(
          failures: ["Oversizing total failure"],
          result:
            .cooling(.init(
              result: .init(
                interpolatedCapacity: .init(total: 23_402, sensible: 18_450),
                excessLatent: 487,
                finalCapacityAtDesign: .init(total: 23_402, sensible: 18_937),
                altitudeDerating: .airToAir(total: 1, sensible: 1, heating: 1),
                capacityAsPercentOfLoad: .init(total: 130.9, sensible: 136.3, latent: 112.2),
                sizingLimits: .init(oversizing: .cooling(total: 130), undersizing: .cooling())
              )
            )))
      )
    }
  }
  
  func test_twoWay() async throws {
    try await withLiveSiteHandler {
      
      @Dependency(\.apiMiddleware) var client
      
      let request = ServerRoute.Api.Route.Interpolation.Cooling.TwoWay(
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
        designInfo: .init(),
        houseLoad: .mock,
        systemType: .default
      )
      
      let apiRequest = ServerRoute.Api(isDebug: true, route: .interpolate(.cooling(.twoWay(request))))
      
      let sut = try await client.respond(apiRequest).value as! InterpolationResponse
      XCTAssertNoDifference(
        sut,
        .init(
          failures: ["Oversizing total failure"],
          result: .cooling(.init(
          result: .init(
            interpolatedCapacity: .init(total: 23_915, sensible: 18_700),
            excessLatent: 618,
            finalCapacityAtDesign: .init(total: 23_915, sensible: 19_318),
            altitudeDerating: .airToAir(total: 1, sensible: 1, heating: 1),
            capacityAsPercentOfLoad: .init(total: 133.8, sensible: 139.0, latent: 115.6),
            sizingLimits: .init(oversizing: .cooling(total: 130), undersizing: .cooling())
          )
        )))
      )
    }
  }

}

extension DesignInfo {
  static var oneWayIndoor: Self {
    var output = Self()
    output.summer.indoorTemperature = 95
    return output
  }
}
