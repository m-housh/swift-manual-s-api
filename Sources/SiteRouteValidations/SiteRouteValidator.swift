import Models
import Validations
import Dependencies

public struct SiteRouteValidator {
  
  let validator: any AsyncValidator<ServerRoute>
  
  public init(_ closure: @escaping (ServerRoute) async throws -> ()) {
    self.init(AsyncValidation(closure))
  }
  
  public init(_ validator: any AsyncValidator<ServerRoute>) {
    self.validator = validator
  }
  
  public init(@AsyncValidationBuilder<ServerRoute> validator: @escaping () -> any AsyncValidator<ServerRoute>) {
    self.init(validator())
  }
  
  public func validate(_ route: ServerRoute) async throws {
    try await self.validator.validate(route)
  }
}

extension SiteRouteValidator: TestDependencyKey {
  static public var testValue = Self.init(Always().async)
}

extension DependencyValues {

  public var siteValidator: SiteRouteValidator {
    get { self[SiteRouteValidator.self] }
    set { self[SiteRouteValidator.self] = newValue }
  }
}

public struct ApiRouteValidator: TestDependencyKey {
  let validator: any AsyncValidator<ServerRoute.Api.Route>
  
  public init(_ validate: @escaping (ServerRoute.Api.Route) async throws -> Void) {
    self.init(AsyncValidation(validate))
  }
  
  public init(_ validator: any AsyncValidator<ServerRoute.Api.Route>) {
    self.validator = validator
  }
  
  public func validate(_ route: ServerRoute.Api.Route) async throws {
    try await self.validator.validate(route)
  }
  
  public static let testValue = Self.init(Always().async)
}

extension DependencyValues {
  public var apiRouteValidator: ApiRouteValidator {
    get { self[ApiRouteValidator.self] }
    set { self[ApiRouteValidator.self] = newValue }
  }
}
