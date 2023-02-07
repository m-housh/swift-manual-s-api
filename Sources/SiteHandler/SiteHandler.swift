import Dependencies
import Models
import SiteRouteValidations
import XCTestDynamicOverlay

public typealias RouteHandler<Request, Response: Encodable> = @Sendable (Request) async throws -> Response

public struct SiteHandler {
  
  @Dependency(\.siteValidator) var siteValidator: SiteRouteValidator
//  @Dependency(\.apiHandler) var apiHandler: ApiHandler
  
  public var api: ApiHandler

  public init(api: ApiHandler) {
    self.api = api
  }
  
  public func respond(_ request: ServerRoute) async throws -> AnyEncodable {
    
    // validate the request.
    try await siteValidator.validate(request)
    
    switch request {
    case let .api(apiRequest):
      return try await api.respond(apiRequest)
    case .home:
      return "\(request)".eraseToAnyEncodable() // fix
    }
  }
}

public struct ApiHandler {
  
  public var balancePoint: RouteHandler<ServerRoute.Api.Route.BalancePointRequest, BalancePointResponse>
  public var derating: RouteHandler<ServerRoute.Api.Route.DeratingRequest, AdjustmentMultiplier>
  public var interpolate: RouteHandler<ServerRoute.Api.Route.InterpolationRequest, InterpolationResponse>
  public var requiredKW: RouteHandler<ServerRoute.Api.Route.RequiredKWRequest, RequiredKWResponse>
  public var sizingLimits: RouteHandler<ServerRoute.Api.Route.SizingLimitRequest, SizingLimits>
  
  public init(
    balancePoint: @escaping RouteHandler<ServerRoute.Api.Route.BalancePointRequest, BalancePointResponse>,
    derating: @escaping RouteHandler<ServerRoute.Api.Route.DeratingRequest, AdjustmentMultiplier>,
    interpolate: @escaping RouteHandler<ServerRoute.Api.Route.InterpolationRequest, InterpolationResponse>,
    requiredKW: @escaping RouteHandler<ServerRoute.Api.Route.RequiredKWRequest, RequiredKWResponse>,
    sizingLimits: @escaping RouteHandler<ServerRoute.Api.Route.SizingLimitRequest, SizingLimits>
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

extension ApiHandler {
  
  public static let unimplemented = Self.init(
    balancePoint: XCTestDynamicOverlay.unimplemented(),
    derating: XCTestDynamicOverlay.unimplemented(),
    interpolate: XCTestDynamicOverlay.unimplemented(),
    requiredKW: XCTestDynamicOverlay.unimplemented(),
    sizingLimits: XCTestDynamicOverlay.unimplemented()
  )
  
  public static let testValue: ApiHandler = .unimplemented
}

extension SiteHandler: TestDependencyKey {
  
  public static let testValue: SiteHandler = .init(api: .unimplemented)
}

extension DependencyValues {
  
  public var siteHandler: SiteHandler {
    get { self[SiteHandler.self] }
    set { self[SiteHandler.self] = newValue }
  }
}
