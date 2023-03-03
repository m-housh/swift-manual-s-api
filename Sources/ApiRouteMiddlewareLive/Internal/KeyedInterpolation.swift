import Models

extension Project {
  func respond() async throws -> InterpolationResponse {
    try await systems.respond(request: self)
  }
}

extension Project.System {
  func respond(request: Project) async throws -> InterpolationResponse.Result.System {
    let coolingRequest = ServerRoute.Api.Route.Interpolation.Single(
      designInfo: request.designInfo,
      houseLoad: request.houseLoad,
      systemType: self.systemType,
      route: .cooling(route: self.cooling)
    )
    
    async let coolingResponse = cooling.respond(request: coolingRequest)
    async let heatingResponse = heating.respond(request: request, systemType: self.systemType)
    return try await .init(
      key: name,
      systemId: systemId,
      cooling: coolingResponse,
      heating: heatingResponse
    )
  }
}

extension Array where Element == Project.System {
  func respond(request: Project) async throws -> InterpolationResponse {
    var responses: [InterpolationResponse.Result.System] = []
    for item in self {
      let value = try await item.respond(request: request)
      responses.append(value)
    }
    return .init(result: .systems(responses))
  }
}

extension Array
where Element == ServerRoute.Api.Route.Interpolation.Single.Route.Heating {
  func respond(request: Project, systemType: SystemType) async throws -> [InterpolationResponse] {
    var responses: [InterpolationResponse] = []
    for item in self {
      let heatingRequest = ServerRoute.Api.Route.Interpolation.Single(
        designInfo: request.designInfo,
        houseLoad: request.houseLoad,
        systemType: systemType, // fix
        route: .heating(route: item)
      )
      let value = try await item.respond(request: heatingRequest)
      responses.append(value)
    }
    return responses
  }
}
