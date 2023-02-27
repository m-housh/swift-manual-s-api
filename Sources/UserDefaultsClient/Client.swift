import Dependencies
import Foundation
import XCTestDynamicOverlay

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Represents interactions with the ``UserDefaults`` storage.
///
///
public struct UserDefaultsClient {

  /// Remove a value for the given key.
  public var removeValue: (Key) -> Void

  /// Set a string value for the given key.
  public var setString: (String, Key) -> Void

  /// Set a url value for the given key.
  public var setUrl: (URL, Key) -> Void

  /// Retrieve a string for the given key.
  public var string: (Key) -> String?

  /// Retrieve a url for the given key.
  public var url: (Key) -> URL?

  public init(
    removeValue: @escaping (Key) -> Void,
    setString: @escaping (String, Key) -> Void,
    setUrl: @escaping (URL, Key) -> Void,
    string: @escaping (Key) -> String?,
    url: @escaping (Key) -> URL?
  ) {
    self.removeValue = removeValue
    self.setString = setString
    self.setUrl = setUrl
    self.string = string
    self.url = url
  }

  public enum Key: String, CaseIterable {
    case anvilApiKey = "com.hvacmath.anvil-api-key"
    case apiBaseUrl = "com.hvacmath.api-base-url"
    case anvilBaseUrl = "com.hvacmath.anvil-base-url"
    case configDirectory = "com.hvacmath.config-directory"
    case templateDirectory = "com.hvacmath.templates-directory"
  }
}

extension UserDefaultsClient {

  public func removeValue(forKey key: Key) {
    self.removeValue(key)
  }

  public func setString(_ string: String, forKey key: Key) {
    setString(string, key)
  }

  public func setUrl(_ url: URL, forKey key: Key) {
    setUrl(url, key)
  }

  public func string(forKey key: Key) -> String? {
    self.string(key)
  }

  public func url(forKey key: Key) -> URL? {
    self.url(key)
  }

}

extension UserDefaultsClient: DependencyKey {

  public static let noop = Self.init(
    removeValue: { _ in },
    setString: { _, _ in },
    setUrl: { _, _ in },
    string: { _ in nil },
    url: { _ in nil }
  )

  public static let testValue: UserDefaultsClient = .init(
    removeValue: unimplemented("\(Self.self).removeValue"),
    setString: unimplemented("\(Self.self).setString"),
    setUrl: unimplemented("\(Self.self).setUrl"),
    string: unimplemented("\(Self.self).string", placeholder: nil),
    url: unimplemented("\(Self.self).url", placeholder: nil)
  )

  public static let liveValue: UserDefaultsClient = .init(
    removeValue: { key in
      UserDefaults.standard.removeObject(forKey: key.rawValue)
    },
    setString: { string, key in
      UserDefaults.standard.set(string, forKey: key.rawValue)
    },
    setUrl: { url, key in
      UserDefaults.standard.set(url, forKey: key.rawValue)
    },
    string: { key in
      UserDefaults.standard.string(forKey: key.rawValue)
    },
    url: { key in
      UserDefaults.standard.url(forKey: key.rawValue)
    }
  )
}

extension DependencyValues {
  public var userDefaults: UserDefaultsClient {
    get { self[UserDefaultsClient.self] }
    set { self[UserDefaultsClient.self] = newValue }
  }
}
