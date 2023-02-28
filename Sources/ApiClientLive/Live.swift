@_exported import ApiClient
import ConcurrencyHelpers
import Dependencies
import Foundation
import Models
import SiteRouter
import UserDefaultsClient

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

// TODO: Use `ConfigClient`
extension ApiClient: DependencyKey {

  public static var liveValue: ApiClient {
    .live()
  }

  public static func live(
    baseUrl defaultBaseUrl: URL = URL(string: "http://localhost:8080")!
  ) -> Self {

    @Dependency(\.userDefaults) var userDefaults

    #if DEBUG
      let baseUrl = userDefaults.url(forKey: .apiBaseUrl) ?? defaultBaseUrl
    #else
      let baseUrl = URL(string: "https://hvacmath.com")!
    #endif

    let router = SiteRouter(decoder: jsonDecoder, encoder: jsonEncoder)

    actor Session {

      nonisolated let baseUrl: Isolated<URL>
      private let router: SiteRouter

      init(baseUrl: URL, router: SiteRouter, userDefaults: UserDefaultsClient) {
        self.baseUrl = .init(
          baseUrl,
          didSet: { _, newValue in
            userDefaults.setUrl(newValue, forKey: .apiBaseUrl)
          }
        )
        self.router = router
      }

      func apiRequest(route: ServerRoute.Api.Route) async throws -> (Data, URLResponse) {
        try await ApiClientLive.apiRequest(
          baseUrl: baseUrl.value,
          route: route,
          router: router
        )
      }

      func request(route: ServerRoute) async throws -> (Data, URLResponse) {
        try await ApiClientLive.request(
          baseUrl: baseUrl.value,
          route: route,
          router: router
        )
      }

      func setBaseUrl(_ url: URL) {
        self.baseUrl.value = url
      }
    }

    let session = Session(baseUrl: baseUrl, router: router, userDefaults: userDefaults)

    return Self(
      apiRequest: { try await session.apiRequest(route: $0) },
      baseUrl: { session.baseUrl.value },
      request: { try await session.request(route: $0) },
      setBaseUrl: { await session.setBaseUrl($0) }
    )
  }
}

private let baseUrlKey = "com.hvacmath.swiftManualS.apiClient.baseUrl"
private let jsonEncoder = JSONEncoder()
private let jsonDecoder = JSONDecoder()

#if DEBUG
  private let isDebug = true
#else
  private let isDebug = false
#endif

private func request(
  baseUrl: URL,
  route: ServerRoute,
  router: SiteRouter
) async throws -> (Data, URLResponse) {
  guard let request = try? router.baseURL(baseUrl.absoluteString).request(for: route) else {
    throw URLError(.badURL)
  }
  #if os(Linux)
    return try await URLSession.shared.asyncData(for: request)
  #else
    if #available(macOS 12.0, iOS 15.0, *) {
      return try await URLSession.shared.data(for: request)
    } else {
      fatalError()
    }
  #endif
}

private func apiRequest(
  baseUrl: URL,
  route: ServerRoute.Api.Route,
  router: SiteRouter
) async throws -> (Data, URLResponse) {
  try await request(
    baseUrl: baseUrl,
    route: .api(
      .init(
        isDebug: isDebug,
        route: route
      )
    ),
    router: router
  )
}
