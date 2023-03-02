import Dependencies
import Foundation
import JsonDependency
import Models
import URLRouting

struct ApiRouter: ParserPrinter {

  @Dependency(\.json.jsonDecoder) var decoder
  @Dependency(\.json.jsonEncoder) var encoder

  @ParserBuilder
  var body: AnyParserPrinter<URLRequestData, ServerRoute.Api.Route> {
    let balancePointRouter = Route(.case(ServerRoute.Api.Route.BalancePoint.thermal)) {
      Method.post
      Path { "thermal" }
      Body(
        .json(
          ServerRoute.Api.Route.BalancePoint.Thermal.self,
          decoder: self.decoder,
          encoder: self.encoder
        )
      )
    }
    OneOf {
      Route(.case(ServerRoute.Api.Route.balancePoint)) {
        Path { RouteKey.balancePoint.key }
        balancePointRouter
      }

      Route(.case(ServerRoute.Api.Route.derating)) {
        Method.post
        Path { RouteKey.derating.key }
        Body(
          .json(
            ServerRoute.Api.Route.Derating.self,
            decoder: self.decoder,
            encoder: self.encoder
          )
        )
      }

      Route(.case(ServerRoute.Api.Route.interpolate)) {
        Method.post
        Path { RouteKey.interpolate.key }
        Body(
          .json(
            ServerRoute.Api.Route.Interpolation.self,
            decoder: self.decoder,
            encoder: self.encoder
          )
        )
      }

      Route(.case(ServerRoute.Api.Route.requiredKW)) {
        Method.post
        Path { RouteKey.requiredKW.key }
        Body(
          .json(
            ServerRoute.Api.Route.RequiredKW.self,
            decoder: self.decoder,
            encoder: self.encoder
          )
        )
      }

      Route(.case(ServerRoute.Api.Route.sizingLimits)) {
        Method.post
        Path { RouteKey.sizingLimits.key }
        Body(
          .json(
            ServerRoute.Api.Route.SizingLimit.self,
            decoder: decoder,
            encoder: encoder
          )
        )
      }
    }
    .eraseToAnyParserPrinter()

  }

  func parse(
    _ input: inout URLRequestData
  ) throws -> ServerRoute.Api.Route {
    try body.parse(&input)
  }

  func print(_ output: ServerRoute.Api.Route, into input: inout URLRequestData) throws {
    try body.print(output, into: &input)
  }
}
