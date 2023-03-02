import CliMiddlewareLive
import Dependencies
import FileClient
import SettingsClientLive
import UserDefaultsClient
import XCTest

final class ConfigTests: XCTestCase {
  
  override func invokeTest() {
    let configClient = withDependencies {
      $0.fileClient = .noop
      $0.userDefaults = .temporary
    } operation: {
      SettingsClient.liveValue
    }
    
    withDependencies {
      $0.json = .liveValue
      $0.settingsClient = configClient
      $0.userDefaults = .temporary
      $0.cliMiddleware = .liveValue
      $0.fileClient = .noop
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
    @Dependency(\.settingsClient) var client
    
    try await config(.set("blob-sr", for: .anvilApiKey))
    var anvilKey = await client.settings().anvilApiKey
    XCTAssertEqual(anvilKey, "blob-sr")
    
    try await config(.set("blob-jr", for: .apiBaseUrl))
    var baseUrl = await client.settings().apiBaseUrl
    XCTAssertEqual(baseUrl, "blob-jr")
    
    try await config(.set("foo", for: .configDirectory))
    let directory = await client.settings().configDirectory
    XCTAssertEqual(directory, "foo")
    
    try await config(.set("blob", for: .templatesDirectory))
    var templates = await client.settings().templateDirectoryPath
    XCTAssertEqual(templates, "blob")
    
    try await config(.unset(.anvilApiKey))
    anvilKey = await client.settings().anvilApiKey
    XCTAssertNil(anvilKey)
    
    try await config(.unset(.apiBaseUrl))
    baseUrl = await client.settings().apiBaseUrl
    XCTAssertNil(baseUrl)
    
    try await config(.unset(.configDirectory))
    
    try await config(.unset(.templatesDirectory))
    templates = await client.settings().templateDirectoryPath
    XCTAssertNil(templates)
  }
}
