import Models

extension Project.System {
  func respond(request: ServerRoute.Api.Route.Interpolation.SingleInterpolation) async throws
    -> InterpolationResponse.Result.System
  {
    async let coolingResponse = cooling.respond(request: request)
    async let heatingResponse = heating.respond(request: request)
    return try await .init(
      key: name, systemId: systemId, cooling: coolingResponse, heating: heatingResponse)
  }
}

extension Array where Element == Project.System {
  func respond(request: ServerRoute.Api.Route.Interpolation.SingleInterpolation) async throws
    -> InterpolationResponse
  {
    var responses: [InterpolationResponse.Result.System] = []
    for item in self {
      let value = try await item.respond(request: request)
      responses.append(value)
    }
    return .init(result: .systems(responses))
  }
}

extension Array
where Element == ServerRoute.Api.Route.Interpolation.SingleInterpolation.Route.Heating {
  func respond(request: ServerRoute.Api.Route.Interpolation.SingleInterpolation) async throws
    -> [InterpolationResponse]
  {
    var responses: [InterpolationResponse] = []
    for item in self {
      let value = try await item.respond(request: request)
      responses.append(value)
    }
    return responses
  }
}
