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

  /// Create a new ``UserDefaultsClient`` instance.
  ///
  /// This is generally not interacted with directly, instead access a client as a dependency.
  /// ```swift
  /// @Dependency(\.userDefaults) var userDefaults
  /// ```
  ///
  /// - Parameters:
  ///   - removeValue: Remove a value for the given key.
  ///   - setString: Set a string for the given key.
  ///   - setUrl: Set a url for the given key.
  ///   - string: Retrieve a string for the given key.
  ///   - url: Retrive a url for the given key.
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

  /// Represents the keys used in user-defaults.
  public enum Key: String, CaseIterable {
    case anvilApiKey = "com.hvacmath.anvil-api-key"
    case apiBaseUrl = "com.hvacmath.api-base-url"
    case anvilBaseUrl = "com.hvacmath.anvil-base-url"
    case configDirectory = "com.hvacmath.config-directory"
    case templateDirectory = "com.hvacmath.templates-directory"
  }
}

extension UserDefaultsClient {

  /// Remove a value for the given key.
  public func removeValue(forKey key: Key) {
    self.removeValue(key)
  }

  /// Set a string value for the given key.
  public func setString(_ string: String, forKey key: Key) {
    setString(string, key)
  }

  /// Set a url value for the given key.
  public func setUrl(_ url: URL, forKey key: Key) {
    setUrl(url, key)
  }

  /// Retrieve a string for the given key.
  public func string(forKey key: Key) -> String? {
    self.string(key)
  }

  /// Retrieve a url for the given key.
  public func url(forKey key: Key) -> URL? {
    self.url(key)
  }

}

extension UserDefaultsClient: DependencyKey {

  /// A ``UserDefaultsClient`` that does not set or retrieve any values.
  ///
  /// This is useful in tests or previews, when you do not want the client to interact with the defaults system
  /// at all, however if any of the methods are called it will not produce values or failures.
  ///
  public static let noop = Self.init(
    removeValue: { _ in },
    setString: { _, _ in },
    setUrl: { _, _ in },
    string: { _ in nil },
    url: { _ in nil }
  )

  /// An unimplemented ``UserDefaultsClient``.
  ///
  public static let testValue: UserDefaultsClient = .init(
    removeValue: unimplemented("\(Self.self).removeValue"),
    setString: unimplemented("\(Self.self).setString"),
    setUrl: unimplemented("\(Self.self).setUrl"),
    string: unimplemented("\(Self.self).string", placeholder: nil),
    url: unimplemented("\(Self.self).url", placeholder: nil)
  )

  /// The live ``UserDefaultsClient``.
  ///
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
  
  /// A ``UserDefaultsClient`` that stores and retrieves values, but does not interact with the
  /// the live defaults system.
  ///
  /// This is helpful in tests or previews, when you need a client that will set / return values, but do not want to persist the values.
  ///
  public static var temporary: UserDefaultsClient {
    class Storage {
      var storage: [UserDefaultsClient.Key: Any]
      init() { self.storage = [:] }
      
      func removeValue(key: UserDefaultsClient.Key) {
        storage[key] = nil
      }
      
      func setString(_ string: String, forKey key: UserDefaultsClient.Key) {
        storage[key] = string
      }
      
      func setUrl(_ url: URL, forKey key: UserDefaultsClient.Key) {
        storage[key] = url
      }
      
      func string(forKey key: UserDefaultsClient.Key) -> String? {
        storage[key] as? String
      }
      
      func url(forKey key: UserDefaultsClient.Key) -> URL? {
        storage[key] as? URL
      }
    }
    
    let storage = Storage()
    
    return .init(
      removeValue: storage.removeValue(key:),
      setString: storage.setString(_:forKey:),
      setUrl: storage.setUrl(_:forKey:),
      string: storage.string(forKey:),
      url: storage.url(forKey:)
    )
  }
}

extension DependencyValues {

  /// Access a ``UserDefaultsClient`` as a dependency.
  ///
  public var userDefaults: UserDefaultsClient {
    get { self[UserDefaultsClient.self] }
    set { self[UserDefaultsClient.self] = newValue }
  }
}
