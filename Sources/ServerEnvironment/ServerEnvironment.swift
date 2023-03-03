import Dependencies
import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct ServerEnvironment: Equatable, Sendable {
  public var baseUrl: URL

  public init(
    baseUrl: URL = URL(string: "http://localhost:8080")!
  ) {
    self.baseUrl = baseUrl
  }

  fileprivate mutating func merge(with other: Self?) {
    self.baseUrl = other?.baseUrl ?? self.baseUrl
  }
}

extension ServerEnvironment: DependencyKey {

  public static let testValue: ServerEnvironment = .init()

  public static let liveValue: ServerEnvironment = .live(
    environment: ProcessInfo.processInfo.environment
  )

  public static func live(environment: [String: String]) -> Self {
    var value = Self.init()
    let data = try! JSONEncoder().encode(environment)
    let environment = try? JSONDecoder().decode(Environment.self, from: data)
    environment?.merge(with: &value)
    return value
  }

  fileprivate struct Environment: Decodable {
    var baseUrl: String?

    enum CodingKeys: String, CodingKey {
      case baseUrl = "EQUIPMENT_SELECTION_BASE_URL"
    }

    func merge(with other: inout ServerEnvironment) {
      if let baseUrlString = baseUrl,
        let baseUrl = URL(string: baseUrlString)
      {
        other.baseUrl = baseUrl
      }
    }
  }
}

extension DependencyValues {

  public var serverEnvironment: ServerEnvironment {
    get { self[ServerEnvironment.self] }
    set { self[ServerEnvironment.self] = newValue }
  }
}
