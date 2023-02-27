import XCTest
import CliConfigLive
import Dependencies
import FileClient
import Logging
import LoggingDependency
import Models
import TemplateClient
import TemplateClientLive
import UserDefaultsClient

@MainActor
final class TemplateClientTests: XCTestCase {
  
  override func invokeTest() {
    let (configClient, templateClient) = withDependencies {
      $0.fileClient = .liveValue
      $0.userDefaults = .noop
    } operation: {
      return (
        CliConfigClient.liveValue,
        TemplateClient.liveValue
      )
    }
    
    withDependencies {
      $0.cliConfigClient = configClient
      $0.templateClient = templateClient
    } operation: {
      super.invokeTest()
    }
  }
  
  func test_loading_templates_when_not_on_file() async throws {
    @Dependency(\.templateClient) var templateClient
    let decoder = JSONDecoder()
    
    for key in Template.PathKey.allCases {
      let data = try await templateClient.template(for: key)
      switch key {
      case .baseInterpolation:
        let decoded = try decoder.decode(Template.BaseInterpolation.self, from: data)
        XCTAssertEqual(decoded, key.mock as! Template.BaseInterpolation)
      case .boiler:
        typealias type = ServerRoute.Api.Route.Interpolation.Route.Heating.Boiler
        let decoded = try decoder.decode(type.self, from: data)
        let mock = key.mock as! type
        XCTAssertEqual(decoded, mock)
      case .electric:
        typealias type = ServerRoute.Api.Route.Interpolation.Route.Heating.Electric
        let decoded = try decoder.decode(type.self, from: data)
        let mock = key.mock as! type
        XCTAssertEqual(decoded, mock)
      case .furnace:
        typealias type = ServerRoute.Api.Route.Interpolation.Route.Heating.Furnace
        let decoded = try decoder.decode(type.self, from: data)
        let mock = key.mock as! type
        XCTAssertEqual(decoded, mock)
      case .heatPump:
        typealias type = ServerRoute.Api.Route.Interpolation.Route.Heating.HeatPump
        let decoded = try decoder.decode(type.self, from: data)
        let mock = key.mock as! type
        XCTAssertEqual(decoded, mock)
      case .keyed:
        typealias type = ServerRoute.Api.Route.Interpolation.Route.Keyed
        let decoded = try decoder.decode([type].self, from: data)
        let mock = key.mock as! [type]
        XCTAssertEqual(decoded, mock)
      case .noInterpolation:
        typealias type = ServerRoute.Api.Route.Interpolation.Route.Cooling.NoInterpolation
        let decoded = try decoder.decode(type.self, from: data)
        let mock = key.mock as! type
        XCTAssertEqual(decoded, mock)
      case .oneWayIndoor:
        typealias type = ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay
        let decoded = try decoder.decode(type.self, from: data)
        let mock = key.mock as! type
        XCTAssertEqual(decoded, mock)
      case .oneWayOutdoor:
        typealias type = ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay
        let decoded = try decoder.decode(type.self, from: data)
        let mock = key.mock as! type
        XCTAssertEqual(decoded, mock)
      case .twoWay:
        typealias type = ServerRoute.Api.Route.Interpolation.Route.Cooling.TwoWay
        let decoded = try decoder.decode(type.self, from: data)
        let mock = key.mock as! type
        XCTAssertEqual(decoded, mock)
      }
    }
  }
  
  func test_generating_templates() async throws {
    
    @Dependency(\.cliConfigClient) var configClient
    
    let tempDirectory = FileManager.default.temporaryDirectory
      .appendingPathComponent("generate-templates-test")
    
    defer { try? FileManager.default.removeItem(at: tempDirectory) }
    
    let templateClient = withDependencies {
      $0.cliConfigClient = configClient
      $0.fileClient = .liveValue
      $0.logger.logLevel = .debug
      $0.userDefaults = .noop
    } operation: {
      return TemplateClient.live(templateDirectory: tempDirectory)
    }
    
    let directoryExists = FileManager.default.fileExists(atPath: tempDirectory.absoluteString)
    XCTAssertFalse(directoryExists)
    
    try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    try await templateClient.generateTemplates()
    
    let decoder = JSONDecoder()
    
    for key in Template.PathKey.allCases {
      let data = try await templateClient.template(for: key)
      switch key {
      case .baseInterpolation:
        let decoded = try decoder.decode(Template.BaseInterpolation.self, from: data)
        XCTAssertEqual(decoded, key.mock as! Template.BaseInterpolation)
      case .boiler:
        typealias type = ServerRoute.Api.Route.Interpolation.Route.Heating.Boiler
        let decoded = try decoder.decode(type.self, from: data)
        let mock = key.mock as! type
        XCTAssertEqual(decoded, mock)
      case .electric:
        typealias type = ServerRoute.Api.Route.Interpolation.Route.Heating.Electric
        let decoded = try decoder.decode(type.self, from: data)
        let mock = key.mock as! type
        XCTAssertEqual(decoded, mock)
      case .furnace:
        typealias type = ServerRoute.Api.Route.Interpolation.Route.Heating.Furnace
        let decoded = try decoder.decode(type.self, from: data)
        let mock = key.mock as! type
        XCTAssertEqual(decoded, mock)
      case .heatPump:
        typealias type = ServerRoute.Api.Route.Interpolation.Route.Heating.HeatPump
        let decoded = try decoder.decode(type.self, from: data)
        let mock = key.mock as! type
        XCTAssertEqual(decoded, mock)
      case .keyed:
        typealias type = ServerRoute.Api.Route.Interpolation.Route.Keyed
        let decoded = try decoder.decode([type].self, from: data)
        let mock = key.mock as! [type]
        XCTAssertEqual(decoded, mock)
      case .noInterpolation:
        typealias type = ServerRoute.Api.Route.Interpolation.Route.Cooling.NoInterpolation
        let decoded = try decoder.decode(type.self, from: data)
        let mock = key.mock as! type
        XCTAssertEqual(decoded, mock)
      case .oneWayIndoor:
        typealias type = ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay
        let decoded = try decoder.decode(type.self, from: data)
        let mock = key.mock as! type
        XCTAssertEqual(decoded, mock)
      case .oneWayOutdoor:
        typealias type = ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay
        let decoded = try decoder.decode(type.self, from: data)
        let mock = key.mock as! type
        XCTAssertEqual(decoded, mock)
      case .twoWay:
        typealias type = ServerRoute.Api.Route.Interpolation.Route.Cooling.TwoWay
        let decoded = try decoder.decode(type.self, from: data)
        let mock = key.mock as! type
        XCTAssertEqual(decoded, mock)
      }
    }
  }
}
