import Dependencies
import Foundation
import LoggingDependency
import Models

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct ApiClient {
  @Dependency(\.logger) var logger

  public var apiRequest: @Sendable (ServerRoute.Api.Route) async throws -> (Data, URLResponse)
  public var baseUrl: @Sendable () -> URL
  public var request: @Sendable (ServerRoute) async throws -> (Data, URLResponse)
  public var setBaseUrl: @Sendable (URL) async -> Void

  public init(
    apiRequest: @Sendable @escaping (ServerRoute.Api.Route) async throws -> (Data, URLResponse),
    baseUrl: @Sendable @escaping () -> URL,
    request: @Sendable @escaping (ServerRoute) async throws -> (Data, URLResponse),
    setBaseUrl: @Sendable @escaping (URL) async -> Void
  ) {
    self.apiRequest = apiRequest
    self.baseUrl = baseUrl
    self.setBaseUrl = setBaseUrl
    self.request = request
  }

  public func apiRequest(
    route: ServerRoute.Api.Route,
    file: StaticString = #file,
    line: UInt = #line
  ) async throws -> (Data, URLResponse) {
    do {
      let (data, response) = try await apiRequest(route)
      logger.debug(
        """
        API: route: \(route) \
        status: \((response as? HTTPURLResponse)?.statusCode ?? 0) \
        data: \(String(decoding: data, as: UTF8.self))
        """
      )
      return (data, response)
    } catch {
      throw ApiError(error: error, file: file, line: line)
    }
  }

  public func apiRequest<A: Decodable>(
    route: ServerRoute.Api.Route,
    as: A.Type,
    file: StaticString = #file,
    line: UInt = #line
  ) async throws -> A {
    let (data, _) = try await self.apiRequest(route: route, file: file, line: line)
    do {
      return try apiDecode(A.self, from: data)
    } catch {
      throw ApiError(error: error, file: file, line: line)
    }
  }
  
  public func interpolate(
    _ interpolation: ServerRoute.Api.Route.Interpolation
  ) async throws -> InterpolationResponse {
    try await self.apiRequest(
      route: .interpolate(interpolation),
      as: InterpolationResponse.self
    )
  }

  public func request(
    route: ServerRoute,
    file: StaticString = #file,
    line: UInt = #line
  ) async throws -> (Data, URLResponse) {
    do {
      let (data, response) = try await self.request(route)
      logger.debug(
        """
        API: route: \(route), \
        status: \((response as? HTTPURLResponse)?.statusCode ?? 0), \
        data: \(String(decoding: data, as: UTF8.self))
        """
      )
      return (data, response)
    } catch {
      throw ApiError(error: error, file: file, line: line)
    }
  }

  public func request<A: Decodable>(
    route: ServerRoute,
    as: A.Type,
    file: StaticString = #file,
    line: UInt = #line
  ) async throws -> A {
    let (data, _) = try await self.request(route: route, file: file, line: line)
    do {
      return try apiDecode(A.self, from: data)
    } catch {
      throw ApiError(error: error, file: file, line: line)
    }
  }
}

let jsonDecoder = JSONDecoder()

public func apiDecode<A: Decodable>(_ type: A.Type, from data: Data) throws -> A {
  do {
    return try jsonDecoder.decode(A.self, from: data)
  } catch let decodingError {
    let apiError: Error
    do {
      apiError = try jsonDecoder.decode(ApiError.self, from: data)
    } catch {
      throw decodingError
    }
    throw apiError
  }
}
