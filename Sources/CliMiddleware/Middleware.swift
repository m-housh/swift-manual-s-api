import Dependencies
import Foundation
import Models
import XCTestDynamicOverlay

public struct CliMiddleware {
  
  public var baseUrl: () -> URL
  public var generatePdf: (ServerRoute.Api.Route.Interpolation, InterpolationResponse) async throws -> Data
  public var interpolate: (ServerRoute.Api.Route.Interpolation) async throws -> InterpolationResponse
  public var readFile: (URL) async throws -> Data
  public var setBaseUrl: (URL) async -> Void
  public var writeFile: (Data, URL) async throws -> Void
  
  public init(
    baseUrl: @escaping () -> URL,
    generatePdf: @escaping (ServerRoute.Api.Route.Interpolation, InterpolationResponse) async throws -> Data,
    interpolate: @escaping (ServerRoute.Api.Route.Interpolation) async throws -> InterpolationResponse,
    readFile: @escaping (URL) async throws -> Data,
    setBaseUrl: @escaping (URL) async -> Void,
    writeFile: @escaping (Data, URL) async throws -> Void
  ) {
    self.baseUrl = baseUrl
    self.generatePdf = generatePdf
    self.interpolate = interpolate
    self.readFile = readFile
    self.setBaseUrl = setBaseUrl
    self.writeFile = writeFile
  }
  
  public func readFile<D: Decodable>(
    from url: URL,
    as type: D.Type
  ) async throws -> D {
    let data = try await self.readFile(url)
    return try JSONDecoder().decode(D.self, from: data)
  }
  
  public func writeFile(_ data: Data, to path: URL) async throws {
    try await writeFile(data, path)
  }
}

extension CliMiddleware: TestDependencyKey {
  
  public static let unimplemented = Self.init(
    baseUrl: XCTestDynamicOverlay.unimplemented("\(Self.self).baseUrl"),
    generatePdf: XCTestDynamicOverlay.unimplemented("\(Self.self).generatePdf"),
    interpolate: XCTestDynamicOverlay.unimplemented("\(Self.self).interpolate"),
    readFile: XCTestDynamicOverlay.unimplemented("\(Self.self).readFile"),
    setBaseUrl: XCTestDynamicOverlay.unimplemented("\(Self.self).setBaseUrl"),
    writeFile: XCTestDynamicOverlay.unimplemented("\(Self.self).writeFile")
  )
  
  public static var testValue: CliMiddleware { .unimplemented }
}

extension DependencyValues {
  public var cliMiddleware: CliMiddleware {
    get { self[CliMiddleware.self] }
    set { self[CliMiddleware.self] = newValue }
  }
}
