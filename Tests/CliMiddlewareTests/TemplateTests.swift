import CliMiddleware
import Dependencies
import FileClient
import JsonDependency
import LoggingDependency
import SettingsClientLive
import TemplateClientLive
import XCTest

final class TemplateTests: XCTestCase {
  
  override func invokeTest() {
    let (clientConfig, templateClient) = withDependencies {
      $0.userDefaults = .temporary
      $0.fileClient = .liveValue
    } operation: {
      (SettingsClient.liveValue, TemplateClient.liveValue)
    }
    
    withDependencies {
      $0.cliMiddleware = .liveValue
      $0.settingsClient = clientConfig
      $0.fileClient = .liveValue
      $0.json = .liveValue
      $0.templateClient = templateClient
      $0.userDefaults = .temporary
    } operation: {
      super.invokeTest()
    }
  }
  
  func test_generating_and_removing_templates() async throws {
    @Dependency(\.cliMiddleware) var cliMiddleware
    
    let tmp = FileManager.default.temporaryDirectory
      .appendingPathComponent("template-test")
    defer { try? FileManager.default.removeItem(at: tmp) }
    
    try await cliMiddleware.config(.set(tmp.absoluteString, for: .templatesDirectory))
    
    try await cliMiddleware.templates(.generate)
    try await cliMiddleware.templates(.remove(force: true))
  }
  
  func test_template() async throws {
    @Dependency(\.cliMiddleware) var cliMiddleware
    
    let tmp = FileManager.default.temporaryDirectory
      .appendingPathComponent("template-test")
    defer { try? FileManager.default.removeItem(at: tmp) }
    try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
    
    try await cliMiddleware.templates(.template(key: .project, outputContext: .copy))
    try await cliMiddleware.templates(.template(key: .project, outputContext: .echo))
    try await cliMiddleware.templates(.template(key: .boiler, embedIn: .interpolation, outputContext: .write(to: tmp)))
    try await cliMiddleware.templates(.template(key: .furnace, embedIn: .route, outputContext: .write(to: tmp)))
  }
}
