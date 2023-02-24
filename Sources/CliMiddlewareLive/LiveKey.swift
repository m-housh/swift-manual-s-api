import ApiClient
@_exported import CliMiddleware
import Dependencies
import Foundation
import Models

struct FixMeError: Error  { }

extension CliMiddleware: DependencyKey {
  
  public static func live(
    baseUrl defaultBaseUrl: URL = URL(string: "http://localhost:8080")!
  ) -> Self {
    @Dependency(\.apiClient) var apiClient
    
    return .init(
      baseUrl: apiClient.baseUrl,
      generatePdf: { _, _ in
        throw FixMeError()
      },
      interpolate: { route in
        try await apiClient.apiRequest(
          route: .interpolate(route),
          as: InterpolationResponse.self
        )
      },
      readFile: { fileUrl in
        try Data(contentsOf: fileUrl)
      },
      setBaseUrl: apiClient.setBaseUrl,
      writeFile: { data, fileUrl in
        try data.write(to: fileUrl)
      }
    )
  }
  
  public static var liveValue: CliMiddleware {
    .live()
  }
}
