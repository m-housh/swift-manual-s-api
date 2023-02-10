import Foundation
import Models
import URLRouting

struct ApiRouter: ParserPrinter {
  let decoder: JSONDecoder
  let encoder: JSONEncoder

  typealias CoolingKey = ServerRoute.Documentation.Route.Interpolation.Cooling
  typealias HeatingKey = ServerRoute.Documentation.Route.Interpolation.Heating

  @ParserBuilder
  var body: AnyParserPrinter<URLRequestData, ServerRoute.Api.Route> {
    let coolingInterpolationRouter = OneOf {
      Route(.case(ServerRoute.Api.Route.InterpolationRequest.Cooling.noInterpolation)) {
        Method.post
        Path { CoolingKey.noInterpolation.rawValue }
        Body(
          .json(
            ServerRoute.Api.Route.InterpolationRequest.Cooling.NoInterpolationRequest.self,
            decoder: self.decoder,
            encoder: self.encoder
          )
        )
      }

      Route(.case(ServerRoute.Api.Route.InterpolationRequest.Cooling.oneWayIndoor)) {
        Method.post
        Path { CoolingKey.oneWayIndoor.rawValue }
        Body(
          .json(
            ServerRoute.Api.Route.InterpolationRequest.Cooling.OneWayRequest.self,
            decoder: self.decoder,
            encoder: self.encoder
          )
        )
      }

      Route(.case(ServerRoute.Api.Route.InterpolationRequest.Cooling.oneWayOutdoor)) {
        Method.post
        Path { CoolingKey.oneWayOutdoor.rawValue }
        Body(
          .json(
            ServerRoute.Api.Route.InterpolationRequest.Cooling.OneWayRequest.self,
            decoder: self.decoder,
            encoder: self.encoder
          )
        )
      }

      Route(.case(ServerRoute.Api.Route.InterpolationRequest.Cooling.twoWay)) {
        Method.post
        Path { CoolingKey.twoWay.rawValue }
        Body(
          .json(
            ServerRoute.Api.Route.InterpolationRequest.Cooling.TwoWayRequest.self,
            decoder: self.decoder,
            encoder: self.encoder
          )
        )
      }
    }

    let heatingInterpolationRouter = OneOf {
      Route(.case(ServerRoute.Api.Route.InterpolationRequest.Heating.boiler)) {
        Method.post
        Path { HeatingKey.boiler.rawValue }
        Body(
          .json(
            ServerRoute.Api.Route.InterpolationRequest.Heating.BoilerRequest.self,
            decoder: self.decoder,
            encoder: self.encoder
          )
        )
      }

      Route(.case(ServerRoute.Api.Route.InterpolationRequest.Heating.electric)) {
        Method.post
        Path { HeatingKey.electric.rawValue }
        Body(
          .json(
            ServerRoute.Api.Route.InterpolationRequest.Heating.ElectricRequest.self,
            decoder: self.decoder,
            encoder: self.encoder
          )
        )
      }

      Route(.case(ServerRoute.Api.Route.InterpolationRequest.Heating.furnace)) {
        Method.post
        Path { HeatingKey.furnace.rawValue }
        Body(
          .json(
            ServerRoute.Api.Route.InterpolationRequest.Heating.FurnaceRequest.self,
            decoder: self.decoder,
            encoder: self.encoder
          )
        )
      }

      Route(.case(ServerRoute.Api.Route.InterpolationRequest.Heating.heatPump)) {
        Method.post
        Path { HeatingKey.heatPump.rawValue }
        Body(
          .json(
            ServerRoute.Api.Route.InterpolationRequest.Heating.HeatPumpRequest.self,
            decoder: self.decoder,
            encoder: self.encoder
          )
        )
      }
    }

    let interpolationRouter = OneOf {
      Route(.case(ServerRoute.Api.Route.InterpolationRequest.cooling)) {
        Path { InterpolationKey.cooling.rawValue }
        coolingInterpolationRouter
      }

      Route(.case(ServerRoute.Api.Route.InterpolationRequest.heating)) {
        Path { InterpolationKey.heating.rawValue }
        heatingInterpolationRouter
      }
    }

    OneOf {
      Route(.case(ServerRoute.Api.Route.balancePoint)) {
        Method.post
        Path { RouteKey.balancePoint.rawValue }
        Body(
          .json(
            ServerRoute.Api.Route.BalancePointRequest.self,
            decoder: self.decoder,
            encoder: self.encoder
          )
        )
      }

      Route(.case(ServerRoute.Api.Route.derating)) {
        Method.post
        Path { RouteKey.derating.rawValue }
        Body(
          .json(
            ServerRoute.Api.Route.DeratingRequest.self,
            decoder: self.decoder,
            encoder: self.encoder
          )
        )
      }

      Route(.case(ServerRoute.Api.Route.interpolate)) {
        Path { RouteKey.interpolate.rawValue }
        interpolationRouter
      }

      Route(.case(ServerRoute.Api.Route.requiredKW)) {
        Method.post
        Path { RouteKey.requiredKW.rawValue }
        Body(
          .json(
            ServerRoute.Api.Route.RequiredKWRequest.self,
            decoder: self.decoder,
            encoder: self.encoder
          )
        )
      }

      Route(.case(ServerRoute.Api.Route.sizingLimits)) {
        Method.post
        Path { RouteKey.sizingLimits.rawValue }
        Body(
          .json(
            ServerRoute.Api.Route.SizingLimitRequest.self,
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
