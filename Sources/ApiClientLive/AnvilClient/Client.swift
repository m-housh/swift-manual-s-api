import Foundation
import Models

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct AnvilClient {
  public var baseUrl: () -> URL
  // TODO: Make a different input / request type.
  public var generatePdf:
    (ServerRoute.Api.Route.Interpolation, InterpolationResponse) async throws -> (Data, URLResponse)
  public var setBaseUrl: (URL) async -> Void
}

extension AnvilClient {
  public enum Route: Codable, Equatable, Sendable {
    case oneWayIndoor
  }
}
