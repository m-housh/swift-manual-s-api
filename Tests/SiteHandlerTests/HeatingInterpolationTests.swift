import XCTest
import CustomDump
import Models
import SiteHandler
import SiteHandlerLive

final class HeatingInterpolationTests: XCTestCase {
  
  let client = SiteHandler.live
  
  func test_furnace() async throws {
    let request = ServerRoute.Api.Route.InterpolationRequest.Heating.FurnaceRequest(
      altitudeDeratings: nil,
      houseLoad: .mock,
      input: 60_000,
      afue: 96
    )
    let sut = try await client.api.interpolate(.heating(.furnace(request)))
    XCTAssertNoDifference(
      sut,
      .heating(
        .init(
          result: .furnace(.init(
            outputCapacity: 57_600,
            finalCapacity: 57_600,
            percentOfLoad: 116
          ))
        )
      )
    )
  }
  
  func test_furnace_fails() async {
    await XCTAssertThrowsError(try await client.api.interpolate(.heating(.furnace(.init(
      houseLoad: .mock, input: 0, afue: 96))))
    )
    await XCTAssertThrowsError(try await client.api.interpolate(.heating(.furnace(.init(
      houseLoad: .mock, input: 10_000, afue: 0))))
    )
    await XCTAssertThrowsError(try await client.api.interpolate(.heating(.furnace(.init(
      houseLoad: .mock, input: 10_000, afue: 101))))
    )
  }
  
  func test_boiler() async throws {
    let request = ServerRoute.Api.Route.InterpolationRequest.Heating.BoilerRequest(
      altitudeDeratings: nil,
      houseLoad: .mock,
      input: 60_000,
      afue: 96
    )
    let sut = try await client.api.interpolate(.heating(.boiler(request)))
    XCTAssertNoDifference(
      sut,
      .heating(.init(
        result: .boiler(.init(outputCapacity: 57_600, finalCapacity: 57_600, percentOfLoad: 116)))
      )
    )
  }
  
  func test_electric_no_heatPump() async throws {
    let request = ServerRoute.Api.Route.InterpolationRequest.Heating.ElectricRequest(
      altitudeDeratings: nil,
      houseLoad: .mock,
      inputKW: 15
    )
    let sut = try await client.api.interpolate(.heating(.electric(request)))
    XCTAssertNoDifference(
      sut,
      .heating(
        .init(
          result: .electric(.init(requiredKW: 14.55, percentOfLoad: 103.1))
        )
      )
    )
  }
  
  func test_electric_fails() async {
    await XCTAssertThrowsError(try await client.api.interpolate(.heating(.electric(.init(houseLoad: .mock, inputKW: 0)))))
  }
  
  func test_heatPump() async throws {
    let request = ServerRoute.Api.Route.InterpolationRequest.Heating.HeatPumpRequest(
      altitudeDeratings: nil,
      capacity: .mock,
      designInfo: .init(),
      houseLoad: .mock
    )
    let sut = try await client.api.interpolate(.heating(.heatPump(request)))
    XCTAssertNoDifference(
      sut,
      .heating(
        .init(
          result: .heatPump(
            .init(
              finalCapacity: .mock,
              capacityAtDesign: 11_308,
              balancePointTemperature: 38.5,
              requiredKW: 11.24
            )
          )
        )
      )
    )
  }
}
