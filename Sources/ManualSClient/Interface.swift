import Models
import XCTestDynamicOverlay

public struct ManualSClient {
  
  public var interpolate: (InterpolationRequest) async throws -> InterpolationResult

  @inlinable
  public init(
    interpolate: @escaping (InterpolationRequest) async throws -> InterpolationResult
  ) {
    self.interpolate = interpolate
  }
}

extension ManualSClient {
  
  public enum InterpolationRequest: Codable, Equatable, Sendable {
    case cooling(CoolingInterpolation)
    case heating(HeatingInterpolation)
  }
  
  public enum InterpolationResult: Codable, Equatable, Sendable {
    case cooling(CoolingInterpolation.Result)
    case heating(HeatingInterpolation.Result)
  }
}

extension ManualSClient {
  public static let noop = Self.init(
    interpolate: unimplemented("\(Self.self).interpolate")
  )
}
