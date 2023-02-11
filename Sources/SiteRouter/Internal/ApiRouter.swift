import Foundation
import Models
import URLRouting

struct ApiRouter: ParserPrinter {
  let decoder: JSONDecoder
  let encoder: JSONEncoder

  @ParserBuilder
  var body: AnyParserPrinter<URLRequestData, ServerRoute.Api.Route> {
    let coolingInterpolationRouter = OneOf {
      Route(.case(ServerRoute.Api.Route.InterpolationRequest.Cooling.noInterpolation)) {
        Method.post
        Path { CoolingKey.noInterpolation.key }
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
        Path { CoolingKey.oneWayIndoor.key }
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
        Path { CoolingKey.oneWayOutdoor.key }
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
        Path { CoolingKey.twoWay.key }
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
        Path { HeatingKey.boiler.key }
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
        Path { HeatingKey.electric.key }
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
        Path { HeatingKey.furnace.key }
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
        Path { HeatingKey.heatPump.key }
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
        Path { InterpolationKey.cooling.key }
        coolingInterpolationRouter
      }

      Route(.case(ServerRoute.Api.Route.InterpolationRequest.heating)) {
        Path { InterpolationKey.heating.key }
        heatingInterpolationRouter
      }
    }

    let balancePointRouter = Route(.case(ServerRoute.Api.Route.BalancePointRequest.thermal)) {
      Method.post
      Path { "thermal" }
      Body(
        .json(
          ServerRoute.Api.Route.BalancePointRequest.Thermal.self,
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
            ServerRoute.Api.Route.DeratingRequest.self,
            decoder: self.decoder,
            encoder: self.encoder
          )
        )
      }

      Route(.case(ServerRoute.Api.Route.interpolate)) {
        Path { RouteKey.interpolate.key }
        interpolationRouter
      }

      Route(.case(ServerRoute.Api.Route.requiredKW)) {
        Method.post
        Path { RouteKey.requiredKW.key }
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
        Path { RouteKey.sizingLimits.key }
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
