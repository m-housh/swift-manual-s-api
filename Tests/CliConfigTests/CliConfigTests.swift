import XCTest
import CliConfig
import CliConfigLive
import Dependencies
import Foundation

@MainActor
final class CliConfigTests: XCTestCase {
  
  func test_config_reads_from_environment() async throws {
    let config = try await withDependencies {
      $0.cliConfigClient = .liveValue
    } operation: {
      @Dependency(\.cliConfigClient) var client
      return try await client.config()
    }
    
    var defaults = CliConfig()
    defaults.anvilApiKey = "secret"
    defaults.apiBaseUrl = URL(string: "http://localhost:8080")!
    defaults.configDirectory = URL(string: "~/.config/custom-equipment-selection")!
    
    XCTAssertEqual(config, defaults)
  }
  
  func test_config_loads_custom() async throws {
    var customConfig = CliConfig()
    let tempDir = FileManager.default.temporaryDirectory
    let customConfigDirectory = tempDir.appendingPathComponent("equipment-selection", conformingTo: .directory)
    
    try FileManager.default.createDirectory(at: customConfigDirectory, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: customConfigDirectory) }
    
    customConfig.configDirectory = customConfigDirectory
    XCTAssertFalse(FileManager.default.fileExists(atPath: customConfig.configPath.absoluteString))
    
    let client = try await withDependencies {
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
