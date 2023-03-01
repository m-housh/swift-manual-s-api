import ClientConfigLive
import CliMiddlewareLive
import Dependencies
import FileClient
import UserDefaultsClient
import XCTest

final class ConfigTests: XCTestCase {
  
  override func invokeTest() {
    let configClient = withDependencies {
      $0.fileClient = .noop
      $0.userDefaults = .temporary
    } operation: {
      ConfigClient.liveValue
    }
    
    withDependencies {
      $0.json = .liveValue
      $0.configClient = configClient
      $0.userDefaults = .temporary
      $0.cliMiddleware = .liveValue
    } operation: {
      super.invokeTest()
    }
  }
  
  func test_generate() async throws {
    @Dependency(\.cliMiddleware) var cliMiddleware
    try await cliMiddleware.config(.generate)
  }
  
  func test_show() async throws {
    @Dependency(\.cliMiddleware) var cliMiddleware
    try await cliMiddleware.config(.show)
  }
  
  func test_set_and_unset() async throws {
    @Dependency(\.cliMiddleware.config) var config
    try await config(.set("blob-sr", for: .anvilApiKey))
    try await config(.set("blob-jr", for: .apiBaseUrl))
    try await config(.set("foo", for: .configDirectory))
    try await config(.set("blob", for: .templatesDirectory))
    try await config(.unset(.anvilApiKey))
    try await config(.unset(.apiBaseUrl))
    try await config(.unset(.configDirectory))
    try await config(.unset(.templatesDirectory))
  }
}
