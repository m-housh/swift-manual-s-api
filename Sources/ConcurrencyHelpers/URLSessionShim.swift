// taken from https://medium.com/hoursofoperation/use-async-urlsession-with-server-side-swift-67821a64fa91
import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

#if os(Linux)
  /// Defines the possible errors
  public enum URLSessionAsyncErrors: Error {
    case invalidUrlResponse, missingResponseData
  }

  /// An extension that provides async support for fetching a URL
  ///
  /// Needed because the Linux version of Swift does not support async URLSession yet.
  extension URLSession {

    /// A reimplementation of `URLSession.shared.data(from: url)` required for Linux
    ///
    /// - Parameter url: The URL for which to load data.
    /// - Returns: Data and response.
    ///
    /// - Usage:
    ///
    ///     let (data, response) = try await URLSession.shared.asyncData(from: url)
    public func asyncData(for request: URLRequest) async throws -> (Data, URLResponse) {
      return try await withCheckedThrowingContinuation { continuation in
        let task = self.dataTask(with: request) { data, response, error in
          if let error = error {
            continuation.resume(throwing: error)
            return
          }
          guard let response = response as? HTTPURLResponse else {
            continuation.resume(throwing: URLSessionAsyncErrors.invalidUrlResponse)
            return
          }
          guard let data = data else {
            continuation.resume(throwing: URLSessionAsyncErrors.missingResponseData)
            return
          }
          continuation.resume(returning: (data, response))
        }
        task.resume()
      }
    }
  }
#endif
