import XCTest
import ApiClientLive
import Dependencies
import FirstPartyMocks
import Models
import UserDefaultsClient
#if canImport(FoundationNetworkin)
import FoundationNetworking
#endif

let baseUrl: URL = {
  guard let baseUrlString = ProcessInfo.processInfo.environment["TEST_CLIENT_BASE_URL"],
        let baseUrl = URL(string: baseUrlString)
  else
  {
    return URL(string: "http://localhost:8080")!
  }
  return baseUrl
}()

class ApiClientLiveTests: XCTestCase {
  
  override func invokeTest() {
    let apiClient = withDependencies {
      $0.userDefaults = .temporary
    } operation: {
      return ApiClient.live(baseUrl: baseUrl)
    }
    
    withDependencies {
      $0.apiClient = apiClient
    } operation: {
      super.invokeTest()
    }
    
  }
  
  func test_balance_point() async throws {
    @Dependency(\.apiClient) var client
    let response = try await client.apiRequest(
      route: .balancePoint(.thermal(.mock)),
      as: BalancePointResponse.self
    )
    XCTAssertEqual(response.balancePoint, 38.5)
  }
  
  func test_derating() async throws {
    @Dependency(\.apiClient) var client
    let response = try await client.apiRequest(
      route: .derating(.mock),
      as: AdjustmentMultiplier.self
    )
    guard case let .airToAir(total: total, sensible: sensible, heating: heating) = response else {
      XCTFail()
      return
    }
    XCTAssertEqual(total, 0.96)
    XCTAssertEqual(sensible, 0.85)
    XCTAssertEqual(heating, 0.92)
    
  }
  
  func test_requiredKW() async throws {
    @Dependency(\.apiClient) var client
    let response = try await client.apiRequest(
      route: .requiredKW(.init(heatLoss: 123456)),
      as: RequiredKWResponse.self
    )
    XCTAssertEqual(response.requiredKW, 36.17)
  }
  
  func test_sizingLimits() async throws {
    @Dependency(\.apiClient) var client
    let response = try await client.apiRequest(
      route: .sizingLimits(.mock),
      as: SizingLimits.self
    )
    
    guard case let .cooling(oversizing) = response.oversizing else {
      XCTFail()
      return
    }
    
    XCTAssertEqual(oversizing.total, 130)
    XCTAssertEqual(oversizing.latent, 150)
    
    guard case let .cooling(undersizing) = response.undersizing else {
      XCTFail()
      return
    }
    XCTAssertEqual(undersizing.total, 90)
    XCTAssertEqual(undersizing.sensible, 90)
    XCTAssertEqual(undersizing.latent, 90)
  }
  
  func test_interpolate_boiler() async throws {
    @Dependency(\.apiClient) var client
    let response = try await client.interpolate(
      .mock(route: .heating(route: .boiler(.mock)))
    )
    XCTAssertFalse(response.isFailed)
  }

  #warning("Fix me.")
//  func test_interpolate_systems() async throws {
//    @Dependency(\.apiClient) var client
//    let response = try await client.interpolate(
//      .mock(route: .systems(.mocks))
//    )
//    XCTAssertFalse(response.isFailed)
//  }
}
