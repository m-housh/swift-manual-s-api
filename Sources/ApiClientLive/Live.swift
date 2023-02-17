@_exported import ApiClient
import Dependencies
import Foundation
import Models
import SiteRouter

#if !os(Linux)
  extension ApiClient: DependencyKey {

    public static var liveValue: ApiClient {
      .live()
    }

    public static func live(
      baseUrl defaultBaseUrl: URL = URL(string: "http://localhost:8080")!
    ) -> Self {
      #if DEBUG
        let baseUrl = UserDefaults.standard.url(forKey: baseUrlKey) ?? defaultBaseUrl
      #else
        let baseUrl = URL(string: "https://hvacmath.com")!
      #endif

      let router = SiteRouter(decoder: jsonDecoder, encoder: jsonEncoder)

      actor Session {
        nonisolated let baseUrl: Isolated<URL>
        private let router: SiteRouter

        init(baseUrl: URL, router: SiteRouter) {
          self.baseUrl = .init(
            baseUrl,
            didSet: { _, newValue in
              UserDefaults.standard.set(newValue, forKey: baseUrlKey)
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

      let session = Session(baseUrl: baseUrl, router: router)

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
    if #available(macOS 12.0, iOS 15.0, *) {
      return try await URLSession.shared.data(for: request)
    } else {
      fatalError()
    }
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
#endif
