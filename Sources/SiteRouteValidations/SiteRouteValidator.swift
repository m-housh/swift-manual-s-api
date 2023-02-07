import Models
import Validations
import Dependencies

public struct SiteRouteValidator {
  
  private let validator: any AsyncValidation<ServerRoute>
  
  public init(_ validator: any AsyncValidation<ServerRoute>) {
    self.validator = validator
  }
  
  public init(_ validator: @escaping (ServerRoute) async throws -> Void) {
    self.validator = AnyAsyncValidator(validator)
  }
  
  public func validate(_ route: ServerRoute) async throws {
    try await self.validator.validate(route)
  }
}

extension SiteRouteValidator: TestDependencyKey {
  static public var testValue: SiteRouteValidator = Self.init(AsyncValidator.fail())
}

extension DependencyValues {

  public var siteValidator: SiteRouteValidator {
    get { self[SiteRouteValidator.self] }
    set { self[SiteRouteValidator.self] = newValue }
  }
}

public struct ApiRouteValidator: TestDependencyKey {
  let validator: any AsyncValidation<ServerRoute.Api.Route>
  
  public init(_ validator: any AsyncValidation<ServerRoute.Api.Route>) {
    self.validator = validator
  }
  
  public init(_ validator: @escaping (ServerRoute.Api.Route) async throws -> Void) {
    self.validator = AnyAsyncValidator(validator)
  }
  
  public func validate(_ route: ServerRoute.Api.Route) async throws {
    try await self.validator.validate(route)
  }
  
  public static let testValue = Self.init(AsyncValidator.fail())
}

//extension DependencyValues {
//  public var apiRouteValidator: ApiRouteValidator {
//    get { self[ApiRouteValidator.self] }
//    set { self[ApiRouteValidator.self] = newValue }
//  }
//}
