import XCTest
import ApiRouteMiddlewareLive
import CustomDump
import Dependencies
import FirstPartyMocks
import Models

@MainActor
final class KeyedInterpolationTests: XCTestCase {
  
  override func invokeTest() {
    withDependencies {
      $0.apiMiddleware = .liveValue
    } operation: {
      super.invokeTest()
    }
  }
  
  func test_keyed_interpolation() async throws {
    @Dependency(\.apiMiddleware) var client
    
    let mock = [Array<ServerRoute.Api.Route.Interpolation.Route.Keyed>.mocks.first!]
    let route = ServerRoute.Api.Route.interpolate(.mock(route: .keyed(mock)))
    let serverRoute = ServerRoute.Api(isDebug: false, route: route)
    let sut = try await client.respond(serverRoute).value as? InterpolationResponse
    XCTAssertNotNil(sut)
    XCTAssertNoDifference(
      sut,
      .init(result: .keyed([
        .init(
          key: "bronze",
          systemId: "bronze-id",
          cooling: .init(result: .cooling(.init(
            result: .init(
              interpolatedCapacity: .init(total: 22_000, sensible: 16_600),
              excessLatent: 711,
              finalCapacityAtDesign: .init(total: 22_000, sensible: 17_311),
              altitudeDerating: .airToAir(total: 1, sensible: 1, heating: 1),
              capacityAsPercentOfLoad: .init(total: 123.1, sensible: 124.6, latent: 117.9),
              sizingLimits: .init(oversizing: .cooling(total: 130), undersizing: .cooling())
            )
          ))),
          heating: [
            .init(result: .heating(.init(
              result: .furnace(.init(
                altitudeDeratings: .heating(multiplier: 1),
                outputCapacity: 57_900,
                finalCapacity: 57_900,
                percentOfLoad: 116.6
              )))))
          ])
      ]))
    )
 }
  
}
