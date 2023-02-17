import Foundation
import Models

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct ApiClient {
  public var apiRequest: @Sendable (ServerRoute.Api.Route) async throws -> (Data, URLResponse)
  public var baseURL: @Sendable () async -> URL
  public var setBaseURL: @Sendable (URL) async -> Void
  public var request: @Sendable (ServerRoute) async throws -> (Data, URLResponse)

  public init(
    apiRequest: @Sendable @escaping (ServerRoute.Api.Route) -> (Data, URLResponse),
    baseURL: @Sendable @escaping () -> URL,
    setBaseURL: @Sendable @escaping (URL) -> Void,
    request: @Sendable @escaping (ServerRoute) -> (Data, URLResponse)
  ) {
    self.apiRequest = apiRequest
    self.baseURL = baseURL
    self.setBaseURL = setBaseURL
    self.request = request
  }

  public func apiRequest(
    route: ServerRoute.Api.Route,
    file: StaticString = #file,
    line: UInt = #line
  ) async throws -> (Data, URLResponse) {
    do {
      let (data, response) = try await apiRequest(route)
      #if DEBUG
        print(
          """
          API: route: \(route) \
          status: \((response as? HTTPURLResponse)?.statusCode ?? 0) \
          data: \(String(decoding: data, as: UTF8.self))
          """
        )
      #endif
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

  public func request(
    route: ServerRoute,
    file: StaticString = #file,
    line: UInt = #line
  ) async throws -> (Data, URLResponse) {
    do {
      let (data, response) = try await self.request(route)
      #if DEBUG
        print(
          """
          API: route: \(route), \
          status: \((response as? HTTPURLResponse)?.statusCode ?? 0), \
          data: \(String(decoding: data, as: UTF8.self))
          """
        )
      #endif
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
