import Models

public enum SiteHandler { }

public struct ApiHandler {
  
  public var balancePointHandler: (ServerRoute.Api.Route.BalancePointRequest) async throws -> BalancePointResponse
//  public var derating: @Sendable (DeratingRequest) async throws -> AdjustmentMultiplier
//  public var requiredKW: @Sendable (RequiredKWRequest) async throws -> RequiredKWResponse
//  public var sizingLimits: @Sendable (ServerRoute.Api.Route.SizingLimitRequest) async throws -> SizingLimits

  
}

//public struct BalancePointHandler {
//  var _respond
//
//  public func respond(request: ServerRoute.Api.Route.BalancePointRequest) async throws -> BalancePointResponse {
//
//  }
//}
//public struct HeatingInterpolationHandler {
//  
//}
