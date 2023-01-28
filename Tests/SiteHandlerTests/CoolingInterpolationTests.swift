import XCTest
import Models
import SiteHandler
import SiteHandlerLive
import CustomDump

final class CoolingInterpolationTests: XCTestCase {
  
  let client = SiteHandler.live
  
  func test_noInterpolation() async throws {
    let request = ServerRoute.Api.Route.InterpolationRequest.Cooling.NoInterpolationRequest(
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
    
    let sut = try await client.api.interpolate(.cooling(.noInterpolation(request)))
    
    XCTAssertNoDifference(sut, .cooling(.init(result: .init(
      interpolatedCapacity: request.capacity.capacity,
      excessLatent: 886,
      finalCapacityAtDesign: .init(total: 22_600, sensible: 17_736),
      altitudeDerating: .airToAir(total: 1, sensible: 1, heating: 1),
      capacityAsPercentOfLoad: .init(total: 126.5, sensible: 127.7, latent: 122.3)))
    ))
  }
  
  func test_oneWayOutdoor() async throws {
    let request = ServerRoute.Api.Route.InterpolationRequest.Cooling.OneWayRequest(
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

    let sut = try await client.api.interpolate(.cooling(.oneWayOutdoor(request)))
    XCTAssertEqual(sut, .cooling(.init(result: .init(
      interpolatedCapacity: .init(total: 22_600, sensible: 16_850),
      excessLatent: 886,
      finalCapacityAtDesign: .init(total: 22_600, sensible: 17_736),
      altitudeDerating: .airToAir(total: 1, sensible: 1, heating: 1),
      capacityAsPercentOfLoad: .init(total: 126.5, sensible: 127.7, latent: 122.3)))
    ))
  }

  func test_oneWayIndoor() async throws {
    let request = ServerRoute.Api.Route.InterpolationRequest.Cooling.OneWayRequest(
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

    let sut = try await client.api.interpolate(.cooling(.oneWayIndoor(request)))
    XCTAssertNoDifference(sut, .cooling(.init(result: .init(
      interpolatedCapacity: .init(total: 23_402, sensible: 18_450),
      excessLatent: 487,
      finalCapacityAtDesign: .init(total: 23_402, sensible: 18_937),
      altitudeDerating: .airToAir(total: 1, sensible: 1, heating: 1),
      capacityAsPercentOfLoad: .init(total: 130.9, sensible: 136.3, latent: 112.2)))
    ))
  }

  func test_twoWay() async throws {
    let request = ServerRoute.Api.Route.InterpolationRequest.Cooling.TwoWayRequest(
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
      designInfo: .init(),
      houseLoad: .mock,
      systemType: .default
    )

    let sut = try await client.api.interpolate(.cooling(.twoWay(request)))
    XCTAssertNoDifference(sut, .cooling(.init(result: .init(
      interpolatedCapacity: .init(total: 23_915, sensible: 18_700),
      excessLatent: 618,
      finalCapacityAtDesign: .init(total: 23_915, sensible: 19_318),
      altitudeDerating: .airToAir(total: 1, sensible: 1, heating: 1),
      capacityAsPercentOfLoad: .init(total: 133.8, sensible: 139.0, latent: 115.6)))
    ))
  }
}

extension DesignInfo {
  static var oneWayIndoor: Self {
    var output = Self()
    output.summer.indoorTemperature = 95
    return output
  }
}
