@_exported import SiteRouteValidations
import Dependencies
import Validations

extension ApiRouteValidator: DependencyKey {
  public static var liveValue: ApiRouteValidator = .init { route in
    switch route {
    case let .balancePoint(balancePoint):
      return try await balancePoint.validate()
    case .derating(_):
      // no validations required.
      return
    case let .interpolate(interpolate):
      return try await interpolate.validate()
    case let .requiredKW(requiredKW):
      return try await requiredKW.validate()
    case let .sizingLimits(sizingLimits):
      return try await sizingLimits.validate()
    }
  }
}

extension SiteRouteValidator: DependencyKey {
  
  public static var liveValue: SiteRouteValidator = .init { route in
    
    let apiRouteValidator = ApiRouteValidator.liveValue
    
    switch route {
    case .home:
      // no validations required.
      return
    case let .api(api):
      return try await apiRouteValidator.validate(api.route)
    }
  }
  
}
