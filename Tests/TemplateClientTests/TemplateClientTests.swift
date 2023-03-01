import XCTest
import ClientConfigLive
import Dependencies
import FileClient
import FirstPartyMocks
import JsonDependency
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
      $0.userDefaults = .temporary
      $0.json.jsonEncoder = .cliEncoder
    } operation: {
      return (
        ConfigClient.liveValue,
        TemplateClient.liveValue
      )
    }
    
    withDependencies {
      $0.configClient = configClient
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
      case .project:
        typealias type = Template.Project
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
    
    @Dependency(\.configClient) var configClient
    
    let tempDirectory = FileManager.default.temporaryDirectory
      .appendingPathComponent("generate-templates-test")
    
    defer {
      try? FileManager.default.removeItem(at: tempDirectory)
    }
    
    let templateClient = withDependencies {
      $0.configClient = configClient
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
      case .project:
        typealias type = Template.Project
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
    
    try await templateClient.removeTemplateDirectory()
  }
  
  func test_setting_directory() async throws {
    @Dependency(\.templateClient) var templateClient
    
    let customDir = URL(fileURLWithPath: "/some/directory")
    await templateClient.setTemplateDirectory(customDir)
    
    let value = templateClient.templateDirectory()
    XCTAssertEqual(value, customDir)
    
  }
  
  func test_embedding_in_interpolation() async throws {
    @Dependency(\.templateClient) var templateClient
    
    let value = try await templateClient.template(
      for: .furnace, inInterpolation: true
    )
    
    let decodedValue = try JSONDecoder().decode(
      ServerRoute.Api.Route.Interpolation.self,
      from: value
    )
    
    XCTAssertEqual(
      decodedValue,
      ServerRoute.Api.Route.Interpolation(
        designInfo: .mock,
        houseLoad: .mock,
        route: .heating(route: .furnace(.mock))
      )
    )
  }
  
  func test_embedding_in_route() async throws {
    @Dependency(\.templateClient) var templateClient
    
    for key in Template.EmbeddableKey.allCases {
      let value = try await templateClient.routeTemplate(for: key)
      switch key {
      case .boiler:
        XCTAssertEqual(value, .heating(route: .boiler(.mock)))
      case .electric:
        XCTAssertEqual(value, .heating(route: .electric(.mock)))
      case .furnace:
        XCTAssertEqual(value, .heating(route: .furnace(.mock)))
      case .heatPump:
        XCTAssertEqual(value, .heating(route: .heatPump(.mock)))
      case .keyed:
        XCTAssertEqual(value, .keyed(.mocks))
      case .noInterpolation:
        XCTAssertEqual(value, .cooling(route: .noInterpolation(.mock)))
      case .oneWayIndoor:
        XCTAssertEqual(value, .cooling(route: .oneWayIndoor(.mock)))
      case .oneWayOutdoor:
        XCTAssertEqual(value, .cooling(route: .oneWayOutdoor(.mock)))
      case .twoWay:
        XCTAssertEqual(value, .cooling(route: .twoWay(.mock)))
      }
    }
    
  }

}
