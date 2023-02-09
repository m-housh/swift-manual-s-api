import XCTest
import Dependencies
import CustomDump
import Models
import RouteHandlerLive
import ValidationMiddlewareLive
import TestSupport

final class HeatingInterpolationTests: XCTestCase {
  
  func test_furnace() async throws {
    try await withLiveSiteHandler {
      
      @Dependency(\.routeHandler) var client: RouteHandler
      
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
  }
  
  func test_boiler() async throws {
    try await withLiveSiteHandler {
      
      @Dependency(\.routeHandler) var client: RouteHandler
      
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
  }
  
  func test_electric_no_heatPump() async throws {
    try await withLiveSiteHandler {
      
      @Dependency(\.routeHandler) var client: RouteHandler
      
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
  }
  
  func test_heatPump() async throws {
    try await withLiveSiteHandler {
      
      @Dependency(\.routeHandler) var client: RouteHandler
      
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
}
