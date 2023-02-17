#if DEBUG
  import Foundation

  #if canImport(FoundationNetworking)
    import FoundationNetworking
  #endif

  public func OK<A: Encodable>(
    _ value: A, encoder: JSONEncoder = .init()
  ) async throws -> (Data, URLResponse) {
    (
      try encoder.encode(value),
      HTTPURLResponse(
        url: URL(string: "/")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    )
  }

  public func OK(_ jsonObject: Any) async throws -> (Data, URLResponse) {
    (
      try JSONSerialization.data(withJSONObject: jsonObject, options: []),
      HTTPURLResponse(
        url: URL(string: "/")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    )
  }
#endif

extension Task where Failure == Never {
  /// An async function that never returns.
  static func never() async throws -> Success {
    for await element in AsyncStream<Success>.never {
      return element
    }
    throw _Concurrency.CancellationError()
  }
}
extension AsyncStream {
  static var never: Self {
    Self { _ in }
  }
}
