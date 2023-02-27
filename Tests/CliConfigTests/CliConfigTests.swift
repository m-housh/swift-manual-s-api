import XCTest
import CliConfig
import CliConfigLive
import CustomDump
import Dependencies
import FileClient
import Foundation
import UserDefaultsClient

@MainActor
final class CliConfigTests: XCTestCase {
  
  override func invokeTest() {
    withDependencies {
      $0.userDefaults = .noop
    } operation: {
      super.invokeTest()
    }
  }
  
  func test_config_reads_from_environment() async throws {
    
    let environment: [String: String] = [
      "ANVIL_API_KEY": "secret",
      "API_BASE_URL": "http://localhost:8081",
      "EQUIPMENT_SELECTION_CONFIG_DIR": "~/.config/custom-equipment-selection",
      "EQUIPMENT_SELECTION_TEMPLATES": "/some/custom/template/location"
    ]
    
     let config = try await withDependencies {
       $0.cliConfigClient = .live(environment: environment)
    } operation: {
      @Dependency(\.cliConfigClient) var client
      return try await client.config()
    }
    
    var defaults = CliConfig()
    defaults.anvilApiKey = "secret"
    defaults.apiBaseUrl = "http://localhost:8081"
    defaults.configDirectory = "~/.config/custom-equipment-selection"
    defaults.templateDirectoryPath = "/some/custom/template/location"
    
    XCTAssertNoDifference(config, defaults)
  }
  
  func test_config_loads_custom() async throws {
    var customConfig = CliConfig()
    let tempDir = FileManager.default.temporaryDirectory
    let customConfigDirectory = tempDir.appendingPathComponent("equipment-selection", conformingTo: .directory)
    print(customConfigDirectory.absoluteString)
    
    try FileManager.default.createDirectory(at: customConfigDirectory, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: customConfigDirectory) }
    try? FileManager.default.removeItem(at: customConfigDirectory)
    
    customConfig.configDirectory = customConfigDirectory.absoluteString
    XCTAssertFalse(FileManager.default.fileExists(atPath: customConfig.configPath.absoluteString))
    
    let client = try await withDependencies {
      $0.userDefaults = .noop
      $0.fileClient = .liveValue
      $0.cliConfigClient = .liveValue
    } operation: {
      @Dependency(\.cliConfigClient) var cliConfigClient
      try await cliConfigClient.save(customConfig)
      return cliConfigClient
    }
    
    let loaded = try await client.config()
    XCTAssertEqual(loaded, customConfig)
  }

}
