import XCTest
import Dependencies
import RouteHandlerLive
import ValidationMiddlewareLive

extension XCTest {
  func XCTAssertThrowsError<T: Sendable>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (_ error: Error) -> Void = { _ in }
  ) async {
    do {
      _ = try await expression()
      XCTFail(message(), file: file, line: line)
    } catch {
      errorHandler(error)
    }
  }
}

func withLiveSiteHandler(
  liveValidator: Bool = false,
  operation: @escaping () async throws -> ()
) async throws {
  try await withDependencies({ dependencies in
    dependencies.validationMiddleware = liveValidator ? .liveValue : .noValidation
    dependencies.routeHandler = .liveValue
  }, operation: {
    try await operation()
  })
}

func withLiveSiteValidator(operation: @escaping () async throws -> ()) async throws {
  try await withDependencies({ dependencies in
    dependencies.validationMiddleware = .liveValue
  }, operation: {
    try await operation()
  })
}
