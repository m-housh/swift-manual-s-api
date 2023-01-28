import Models
import XCTestDynamicOverlay

public typealias RouteHandler<Request, Response: Encodable> = @Sendable (Request) async throws -> Response

public struct SiteHandler {
  public var api: ApiHandler
  
  public init(api: ApiHandler) {
    self.api = api
  }
}

public struct ApiHandler {
  
  public var balancePoint: RouteHandler<ServerRoute.Api.Route.BalancePointRequest, BalancePointResponse>
  public var derating: RouteHandler<ServerRoute.Api.Route.Derating, AdjustmentMultiplier>
  public var interpolate: RouteHandler<ServerRoute.Api.Route.InterpolationRequest, InterpolationResponse>
  public var requiredKW: RouteHandler<ServerRoute.Api.Route.RequiredKW, RequiredKWResponse>
  public var sizingLimits: RouteHandler<ServerRoute.Api.Route.SizingLimitRequest, SizingLimits>
  
  public init(
    balancePoint: @escaping RouteHandler<ServerRoute.Api.Route.BalancePointRequest, BalancePointResponse>,
    derating: @escaping RouteHandler<ServerRoute.Api.Route.Derating, AdjustmentMultiplier>,
    interpolate: @escaping RouteHandler<ServerRoute.Api.Route.InterpolationRequest, InterpolationResponse>,
    requiredKW: @escaping RouteHandler<ServerRoute.Api.Route.RequiredKW, RequiredKWResponse>,
    sizingLimits: @escaping RouteHandler<ServerRoute.Api.Route.SizingLimitRequest, SizingLimits>
  ) {
    self.balancePoint = balancePoint
    self.derating = derating
    self.interpolate = interpolate
    self.requiredKW = requiredKW
    self.sizingLimits = sizingLimits
  }

}

// MARK: - Unimplemented

extension ApiHandler {
  
  public static let unimplemented = Self.init(
    balancePoint: XCTestDynamicOverlay.unimplemented(),
    derating: XCTestDynamicOverlay.unimplemented(),
    interpolate: XCTestDynamicOverlay.unimplemented(),
    requiredKW: XCTestDynamicOverlay.unimplemented(),
    sizingLimits: XCTestDynamicOverlay.unimplemented()
  )
}

extension SiteHandler {
  public static let unimplemented = Self.init(api: .unimplemented)
}
