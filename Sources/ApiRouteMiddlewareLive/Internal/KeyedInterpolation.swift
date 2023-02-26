import Models

extension ServerRoute.Api.Route.Interpolation.Route.Keyed {
  func respond(request: ServerRoute.Api.Route.Interpolation) async throws
    -> InterpolationResponse.Result.Keyed
  {
    async let coolingResponse = cooling.respond(request: request)
    async let heatingResponse = heating.respond(request: request)
    return try await .init(key: name, cooling: coolingResponse, heating: heatingResponse)
  }
}

extension Array where Element == ServerRoute.Api.Route.Interpolation.Route.Keyed {
  func respond(request: ServerRoute.Api.Route.Interpolation) async throws -> InterpolationResponse {
    var responses: [InterpolationResponse.Result.Keyed] = []
    for item in self {
      let value = try await item.respond(request: request)
      responses.append(value)
    }
    return .init(result: .keyed(responses))
  }
}

extension Array where Element == ServerRoute.Api.Route.Interpolation.Route.Heating {
  func respond(request: ServerRoute.Api.Route.Interpolation) async throws -> [InterpolationResponse]
  {
    var responses: [InterpolationResponse] = []
    for item in self {
      let value = try await item.respond(request: request)
      responses.append(value)
    }
    return responses
  }
}
