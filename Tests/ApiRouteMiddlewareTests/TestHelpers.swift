import XCTest
import Dependencies
import ApiRouteMiddlewareLive
import Models

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
    dependencies.apiMiddleware = .liveValue
  }, operation: {
    try await operation()
  })
}

extension ServerRoute.Api.Route.Interpolation {
  
  static func mock(route: ServerRoute.Api.Route.Interpolation.Single.Route) -> Self {
    .init(
      designInfo: .mock,
      houseLoad: .mock,
      systemType: .mock,
      route: route
    )
  }
}
