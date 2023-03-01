import Dependencies
import UserDefaultsClient
import XCTest

final class UserDefaultsClientTests: XCTestCase {
  
  override func invokeTest() {
    withDependencies {
      $0.userDefaults = .temporary
    } operation: {
      super.invokeTest()
    }
  }
  
  func test_setting_string() {
    @Dependency(\.userDefaults) var userDefaults
    
    let currentValue = userDefaults.string(forKey: .apiBaseUrl)
    XCTAssertNil(currentValue)
    userDefaults.setString("blob", forKey: .apiBaseUrl)
    XCTAssertEqual(userDefaults.string(forKey: .apiBaseUrl), "blob")
    
    userDefaults.removeValue(forKey: .apiBaseUrl)
    XCTAssertNil(userDefaults.string(forKey: .apiBaseUrl))
  }
  
  func test_url() {
    @Dependency(\.userDefaults) var userDefaults
    
    let currentValue = userDefaults.url(forKey: .configDirectory)
    XCTAssertNil(currentValue)
    
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("userDefaults-test")
    userDefaults.setUrl(url, forKey: .configDirectory)
    XCTAssertEqual(userDefaults.url(forKey: .configDirectory), url)
    
    userDefaults.removeValue(forKey: .configDirectory)
    XCTAssertNil(userDefaults.string(forKey: .configDirectory))
    userDefaults.setString(url.absoluteString, forKey: .configDirectory)
    XCTAssertEqual(userDefaults.url(forKey: .configDirectory), url)
  }
}
