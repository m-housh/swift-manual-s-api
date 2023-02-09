import Dependencies
import Models
import XCTestDynamicOverlay

public typealias HandlerType<Request, Response: Encodable> = @Sendable (Request) async throws ->
  Response

public struct ApiRouteMiddleware {

  public var balancePoint:
    HandlerType<
      ServerRoute.Api.Route.BalancePointRequest,
      BalancePointResponse
    >

  public var derating:
    HandlerType<
      ServerRoute.Api.Route.DeratingRequest,
      AdjustmentMultiplier
    >

  public var interpolate:
    HandlerType<
      ServerRoute.Api.Route.InterpolationRequest,
      InterpolationResponse
    >

  public var requiredKW:
    HandlerType<
      ServerRoute.Api.Route.RequiredKWRequest,
      RequiredKWResponse
    >

  public var sizingLimits:
    HandlerType<
      ServerRoute.Api.Route.SizingLimitRequest,
      SizingLimits
    >

  public init(
    balancePoint: @escaping HandlerType<
      ServerRoute.Api.Route.BalancePointRequest,
      BalancePointResponse
    >,
    derating: @escaping HandlerType<ServerRoute.Api.Route.DeratingRequest, AdjustmentMultiplier>,
    interpolate: @escaping HandlerType<
      ServerRoute.Api.Route.InterpolationRequest,
      InterpolationResponse
    >,
    requiredKW: @escaping HandlerType<ServerRoute.Api.Route.RequiredKWRequest, RequiredKWResponse>,
    sizingLimits: @escaping HandlerType<ServerRoute.Api.Route.SizingLimitRequest, SizingLimits>
  ) {
    self.balancePoint = balancePoint
    self.derating = derating
    self.interpolate = interpolate
    self.requiredKW = requiredKW
    self.sizingLimits = sizingLimits
  }

  public func respond(_ request: ServerRoute.Api) async throws -> AnyEncodable {

    switch request.route {
    case let .balancePoint(balancePointRequest):
      return try await balancePoint(balancePointRequest).eraseToAnyEncodable()
    case let .derating(deratingRequest):
      return try await derating(deratingRequest).eraseToAnyEncodable()
    case let .interpolate(interpolationRequest):
      return try await self.interpolate(interpolationRequest).eraseToAnyEncodable()
    case let .requiredKW(requiredKWRequest):
      return try await self.requiredKW(requiredKWRequest).eraseToAnyEncodable()
    case let .sizingLimits(sizingLimitRequest):
      return try await self.sizingLimits(sizingLimitRequest).eraseToAnyEncodable()
    }
  }

}

// MARK: - Unimplemented

extension ApiRouteMiddleware: TestDependencyKey {

  public static let unimplemented = Self.init(
    balancePoint: XCTestDynamicOverlay.unimplemented(),
    derating: XCTestDynamicOverlay.unimplemented(),
    interpolate: XCTestDynamicOverlay.unimplemented(),
    requiredKW: XCTestDynamicOverlay.unimplemented(),
    sizingLimits: XCTestDynamicOverlay.unimplemented()
  )

  public static let testValue: ApiRouteMiddleware = .unimplemented
}

extension DependencyValues {

  public var apiMiddleware: ApiRouteMiddleware {
    get { self[ApiRouteMiddleware.self] }
    set { self[ApiRouteMiddleware.self] = newValue }
  }
}
