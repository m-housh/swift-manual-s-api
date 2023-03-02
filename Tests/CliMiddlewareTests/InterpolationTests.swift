import ApiClient
import CasePaths
import CliMiddleware
import Dependencies
import FileClient
import FirstPartyMocks
import JsonDependency
import Models
import SettingsClientLive
import TemplateClientLive
import UserDefaultsClient
import XCTest


final class InterpolationTests: XCTestCase {
  
  override func invokeTest() {
    let projectData = try! JSONEncoder().encode(Template.Project.mock)
    let fileClient = FileClient.mock(readData: projectData)
    
    let (configClient, templateClient) = withDependencies {
      $0.fileClient = .liveValue
      $0.userDefaults = .temporary
    } operation: {
      (SettingsClient.liveValue, TemplateClient.liveValue)
    }
    
    let apiResponse = InterpolationResponse(
      result: .heating(.init(
        result: .boiler(.init(
          altitudeDeratings: .mock,
          outputCapacity: 1234,
          finalCapacity: 1234,
          percentOfLoad: 10
        ))
      ))
    )
    
    var apiClient = ApiClient.noop
      
    apiClient.override(
      routeCase: /ServerRoute.Api.Route.interpolate,
      withResponse: { _ in try await OK(apiResponse) }
    )
    
    withDependencies {
      $0.apiClient = apiClient
      $0.settingsClient = configClient
      $0.cliMiddleware = .liveValue
      $0.fileClient = fileClient
      $0.json = .liveValue
      $0.templateClient = templateClient
      $0.userDefaults = .temporary
    } operation: {
      super.invokeTest()
    }

  }
  
  func test_interpolation() async throws {
    @Dependency(\.cliMiddleware) var cliMiddleware
    
    let tmp = FileManager.default.temporaryDirectory
      .appendingPathComponent("interpolation-test")
    defer { try? FileManager.default.removeItem(at: tmp) }
    
    try await cliMiddleware.interpolate(.init(
      key: .project,
      generatePdf: false,
      inputFile: tmp,
      outputPath: tmp,
      writeJson: true
    ))
  }
  
  func test_interpolation_no_urls() async throws {
    @Dependency(\.cliMiddleware) var cliMiddleware
    
    try await cliMiddleware.interpolate(.init(
      key: .project,
      generatePdf: false,
      inputFile: nil,
      outputPath: nil,
      writeJson: true
    ))
  }
  
  func test_interpolation_echo() async throws {
    @Dependency(\.cliMiddleware) var cliMiddleware
    
    try await cliMiddleware.interpolate(.init(
      key: .project,
      generatePdf: false,
      inputFile: nil,
      outputPath: nil,
      writeJson: false
    ))
  }
}
