import XCTest
import SettingsClient
import SettingsClientLive
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
      $0.fileClient = .liveValue
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
    
     let config = await withDependencies {
       $0.settingsClient = .live(environment: environment)
    } operation: {
      @Dependency(\.settingsClient) var client
      return await client.settings()
    }
    
    var defaults = Settings()
    defaults.anvilApiKey = "secret"
    defaults.apiBaseUrl = "http://localhost:8081"
    defaults.configDirectory = "~/.config/custom-equipment-selection"
    defaults.templateDirectoryPath = "/some/custom/template/location"
    
    XCTAssertNoDifference(config, defaults)
  }
  
  func test_config_loads_custom() async throws {
    var customConfig = Settings()
    let tempDir = FileManager.default.temporaryDirectory
    let customConfigDirectory = tempDir.appendingPathComponent("equipment-selection", conformingTo: .directory)
    print(customConfigDirectory.absoluteString)
    
    try FileManager.default.createDirectory(at: customConfigDirectory, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: customConfigDirectory) }
    try? FileManager.default.removeItem(at: customConfigDirectory)
    
    customConfig.configDirectory = customConfigDirectory.absoluteString
    XCTAssertFalse(FileManager.default.fileExists(atPath: customConfig.configFileUrl.absoluteString))
    
    let client = try await withDependencies {
      $0.userDefaults = .noop
      $0.fileClient = .liveValue
      $0.settingsClient = .liveValue
    } operation: {
      @Dependency(\.settingsClient) var cliConfigClient
      try await cliConfigClient.save(customConfig)
      return cliConfigClient
    }
    
    let loaded = await client.settings()
    XCTAssertEqual(loaded, customConfig)
  }
  
  func test_userDefaults_sets_custom_config_directory() async throws {
    
    let client = withDependencies {
      $0.userDefaults = .temporary
    } operation: {
      return SettingsClient.liveValue
    }
    
    let configBefore = await client.settings()
    XCTAssertNotEqual(configBefore.configDirectory, "/some/config/directory")
    await client.setConfigDirectory("/some/config/directory")
    let configAfter = await client.settings()
    XCTAssertEqual(configAfter.configDirectory, "/some/config/directory")

  }

}
