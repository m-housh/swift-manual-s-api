import XCTest
import Dependencies
import CustomDump
import Models
import ApiRouteMiddlewareLive
import FirstPartyMocks

@MainActor
final class HeatingInterpolationTests: XCTestCase {
  
  func test_furnace() async throws {
    try await withLiveSiteHandler {
      
      @Dependency(\.apiMiddleware) var client
      
      let route = ServerRoute.Api.Route.InterpolationRequest.Heating.FurnaceRequest(
        altitudeDeratings: nil,
        houseLoad: .mock,
        input: 60_000,
        afue: 96
      )
      
      let apiRequest = ServerRoute.Api(isDebug: true, route: .interpolate(.heating(.furnace(route))))
      let sut = try await client.respond(apiRequest).value as! InterpolationResponse
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
      
      @Dependency(\.apiMiddleware) var client
      
      let request = ServerRoute.Api.Route.InterpolationRequest.Heating.BoilerRequest(
        altitudeDeratings: nil,
        houseLoad: .mock,
        input: 60_000,
        afue: 96
      )
      let apiRequest = ServerRoute.Api(isDebug: true, route: .interpolate(.heating(.boiler(request))))
      let sut = try await client.respond(apiRequest).value as! InterpolationResponse
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
      
      @Dependency(\.apiMiddleware) var client
      
      let request = ServerRoute.Api.Route.InterpolationRequest.Heating.ElectricRequest(
        altitudeDeratings: nil,
        houseLoad: .mock,
        inputKW: 15
      )
      let apiRequest = ServerRoute.Api(isDebug: true, route: .interpolate(.heating(.electric(request))))
      
      let sut = try await client.respond(apiRequest).value as! InterpolationResponse
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
      
      @Dependency(\.apiMiddleware) var client
      
      let request = ServerRoute.Api.Route.InterpolationRequest.Heating.HeatPumpRequest(
        altitudeDeratings: nil,
        capacity: .mock,
        designInfo: .init(),
        houseLoad: .mock
      )
      let apiRequest = ServerRoute.Api(isDebug: true, route: .interpolate(.heating(.heatPump(request))))
      let sut = try await client.respond(apiRequest).value as! InterpolationResponse
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
