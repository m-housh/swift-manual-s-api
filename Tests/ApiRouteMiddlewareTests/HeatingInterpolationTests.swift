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
      
      let route = ServerRoute.Api.Route.Interpolation.Route.Heating.Furnace(
        input: 60_000,
        afue: 96
      )
      
      let apiRequest = ServerRoute.Api(
        isDebug: true,
        route: .interpolate(.init(
          designInfo: .mock,
          houseLoad: .mock,
          route: .heating(route: .furnace(route))
        ))
      )
      let sut = try await client.respond(apiRequest).value as! InterpolationResponse
      XCTAssertNoDifference(
        sut,
        .init(result: .heating(
          .init(
            result: .furnace(.init(
              altitudeDeratings: .heating(multiplier: 1),
              outputCapacity: 57_600,
              finalCapacity: 57_600,
              percentOfLoad: 116
            ))
          )
        ))
      )
    }
  }
  
  func test_oversized_furnace() async throws {
    try await withLiveSiteHandler {
      
      @Dependency(\.apiMiddleware) var client
      
      let route = ServerRoute.Api.Route.Interpolation.Route.Heating.Furnace(
        input: 160_000,
        afue: 96
      )
      
      let apiRequest = ServerRoute.Api(
        isDebug: true,
        route: .interpolate(.init(
          designInfo: .mock,
          houseLoad: .mock,
          route: .heating(route: .furnace(route))
        ))
      )
            
      let sut = try await client.respond(apiRequest).value as! InterpolationResponse
      XCTAssertNoDifference(
        sut,
        .init(
          failures: ["Oversizing failure."],
          result: .heating(
          .init(
            result: .furnace(.init(
              altitudeDeratings: .heating(multiplier: 1),
              outputCapacity: 153_600,
              finalCapacity: 153_600,
              percentOfLoad: 309.3
            ))
          )
        ))
      )
    }
  }
  
  func test_boiler() async throws {
    try await withLiveSiteHandler {
      
      @Dependency(\.apiMiddleware) var client
      
      let request = ServerRoute.Api.Route.Interpolation.Route.Heating.Boiler(
        input: 60_000,
        afue: 96
      )
      let apiRequest = ServerRoute.Api(
        isDebug: true,
        route: .interpolate(.init(
          designInfo: .mock,
          houseLoad: .mock,
          route: .heating(route: .boiler(request))
        ))
      )
      let sut = try await client.respond(apiRequest).value as! InterpolationResponse
      XCTAssertNoDifference(
        sut,
        .init(result: .heating(.init(
          result: .boiler(.init(
            altitudeDeratings: .heating(multiplier: 1),
            outputCapacity: 57_600,
            finalCapacity: 57_600,
            percentOfLoad: 116))
        )))
      )
    }
  }
  
  func test_oversized_boiler() async throws {
    try await withLiveSiteHandler {
      
      @Dependency(\.apiMiddleware) var client
      
      let route = ServerRoute.Api.Route.Interpolation.Route.heating(
        route: .boiler(.init(
          input: 160_000,
          afue: 96
        ))
      )
      
      let apiRequest = ServerRoute.Api(isDebug: true, route: .interpolate(.mock(route: route)))
      let sut = try await client.respond(apiRequest).value as! InterpolationResponse
      XCTAssertNoDifference(
        sut,
        .init(
          failures: ["Oversizing failure."],
          result: .heating(
          .init(
            result: .boiler(.init(
              altitudeDeratings: .heating(multiplier: 1),
              outputCapacity: 153_600,
              finalCapacity: 153_600,
              percentOfLoad: 309.3
            ))
          )
        ))
      )
    }
  }
  
  func test_electric_no_heatPump() async throws {
    try await withLiveSiteHandler {
      
      @Dependency(\.apiMiddleware) var client
      
      let request = ServerRoute.Api.Route.Interpolation.Route.heating(
        route: .electric(.init(
        inputKW: 15
      )))
      let apiRequest = ServerRoute.Api(isDebug: true, route: .interpolate(.mock(route: request)))
      
      let sut = try await client.respond(apiRequest).value as! InterpolationResponse
      XCTAssertNoDifference(
        sut,
        .init(result: .heating(
          .init(
            result: .electric(.init(requiredKW: 14.55, percentOfLoad: 103.1))
          ))
        )
      )
    }
  }
  
  func test_oversized_electric_no_heatPump() async throws {
    try await withLiveSiteHandler {
      
      @Dependency(\.apiMiddleware) var client
      
      let request = ServerRoute.Api.Route.Interpolation.Route.heating(
        route: .electric(.init(
          inputKW: 115
        ))
      )
      let apiRequest = ServerRoute.Api(isDebug: true, route: .interpolate(.mock(route: request)))
      
      let sut = try await client.respond(apiRequest).value as! InterpolationResponse
      XCTAssertNoDifference(
        sut,
        .init(
          failures: ["Oversizing failure."],
          result: .heating(
          .init(
            result: .electric(.init(requiredKW: 14.55, percentOfLoad: 790.4))
          ))
        )
      )
    }
  }
  
  func test_heatPump() async throws {
    try await withLiveSiteHandler {
      
      @Dependency(\.apiMiddleware) var client
      
      let request = ServerRoute.Api.Route.Interpolation.Route.heating(
        route: .heatPump(.init(
          capacity: .mock
        ))
      )
      let apiRequest = ServerRoute.Api(isDebug: true, route: .interpolate(.mock(route: request)))
      let sut = try await client.respond(apiRequest).value as! InterpolationResponse
      XCTAssertNoDifference(
        sut,
        .init(result: .heating(
          .init(
            result: .heatPump(
              .init(
                altitudeDeratings: .airToAir(total: 1, sensible: 1, heating: 1),
                finalCapacity: .mock,
                capacityAtDesign: 11_308,
                balancePointTemperature: 38.5,
                requiredKW: 11.24
              )
            )
          )
        ))
      )
    }
  }
}

