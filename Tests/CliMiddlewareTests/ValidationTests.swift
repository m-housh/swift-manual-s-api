import CliMiddlewareLive
import Dependencies
import FileClient
import FirstPartyMocks
import JsonDependency
import Models
import SettingsClientLive
import TemplateClientLive
import UserDefaultsClient
import ValidationMiddlewareLive
import XCTest

final class ValidationTests: XCTestCase {
  
  override func invokeTest() {
    let projectData = try! JSONEncoder().encode(Project.mock)
    let fileClient = FileClient.mock(readData: projectData)

    let configClient = withDependencies {
      $0.fileClient = fileClient
      $0.userDefaults = .temporary
    } operation: {
      SettingsClient.liveValue
    }

    withDependencies {
      $0.settingsClient = configClient
      $0.json = .liveValue
      $0.fileClient = fileClient
    } operation: {
      super.invokeTest()
    }

  }
  
  func test_validations() async throws {
    try await withDependencies {
      $0.validationMiddleware = .liveValue
      $0.cliMiddleware = .liveValue
    } operation: {
      @Dependency(\.cliMiddleware) var cliMiddleware
      let tmp = URL(fileURLWithPath: "/some/where/that/is/not/there/because/we/mock/the/file/client")

      try await cliMiddleware.validate(.init(key: .project, inputFile: tmp))
    }

  }
  
//  func test_all_validations() async throws {
//    for key in Template.PathKey.allCases {
//      if key != .baseInterpolation {
//        let data = try! JSONEncoder().encode(key.mock)
//        let fileClient = FileClient.mock(readData: data)
//
//        let configClient = withDependencies {
//          $0.fileClient = fileClient
//          $0.userDefaults = .temporary
//        } operation: {
//          ConfigClient.liveValue
//        }
//
//        await withDependencies {
//          $0.configClient = configClient
//          $0.fileClient = fileClient
//          $0.json = .liveValue
//          $0.validationMiddleware = .liveValue
//          $0.cliMiddleware = .liveValue
//        } operation: {
//          @Dependency(\.cliMiddleware) var cliMiddleware
//          let tmp = URL(fileURLWithPath: "/foo/bar")
//          do {
//            try await cliMiddleware.validate(.init(key: key, inputFile: tmp))
//          } catch {
//            print("Internal error")
//            print("\(error)")
//          }
//        }
//
//      }
//    }
//  }
}
