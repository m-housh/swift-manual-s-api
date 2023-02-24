import Foundation
import Models
import URLRouting

struct ApiRouter: ParserPrinter {
  let decoder: JSONDecoder
  let encoder: JSONEncoder

  @ParserBuilder
  var body: AnyParserPrinter<URLRequestData, ServerRoute.Api.Route> {
    //    let coolingInterpolationRouter = OneOf {
    //      Route(.case(ServerRoute.Api.Route.Interpolation.Route.Cooling.noInterpolation)) {
    //        Method.post
    //        Path { CoolingKey.noInterpolation.key }
    //        Body(
    //          .json(
    //            ServerRoute.Api.Route.Interpolation.Route.Cooling.NoInterpolation.self,
    //            decoder: self.decoder,
    //            encoder: self.encoder
    //          )
    //        )
    //      }
    //
    //      Route(.case(ServerRoute.Api.Route.Interpolation.Route.Cooling.oneWayIndoor)) {
    //        Method.post
    //        Path { CoolingKey.oneWayIndoor.key }
    //        Body(
    //          .json(
    //            ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay.self,
    //            decoder: self.decoder,
    //            encoder: self.encoder
    //          )
    //        )
    //      }
    //
    //      Route(.case(ServerRoute.Api.Route.Interpolation.Route.Cooling.oneWayOutdoor)) {
    //        Method.post
    //        Path { CoolingKey.oneWayOutdoor.key }
    //        Body(
    //          .json(
    //            ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay.self,
    //            decoder: self.decoder,
    //            encoder: self.encoder
    //          )
    //        )
    //      }
    //
    //      Route(.case(ServerRoute.Api.Route.Interpolation.Route.Cooling.twoWay)) {
    //        Method.post
    //        Path { CoolingKey.twoWay.key }
    //        Body(
    //          .json(
    //            ServerRoute.Api.Route.Interpolation.Route.Cooling.TwoWay.self,
    //            decoder: self.decoder,
    //            encoder: self.encoder
    //          )
    //        )
    //      }
    //    }

    //    let heatingInterpolationRouter = OneOf {
    //      Route(.case(ServerRoute.Api.Route.Interpolation.Route.Heating.boiler)) {
    //        Method.post
    //        Path { HeatingKey.boiler.key }
    //        Body(
    //          .json(
    //            ServerRoute.Api.Route.Interpolation.Route.Heating.Boiler.self,
    //            decoder: self.decoder,
    //            encoder: self.encoder
    //          )
    //        )
    //      }
    //
    //      Route(.case(ServerRoute.Api.Route.Interpolation.Route.Heating.electric)) {
    //        Method.post
    //        Path { HeatingKey.electric.key }
    //        Body(
    //          .json(
    //            ServerRoute.Api.Route.Interpolation.Route.Heating.Electric.self,
    //            decoder: self.decoder,
    //            encoder: self.encoder
    //          )
    //        )
    //      }
    //
    //      Route(.case(ServerRoute.Api.Route.Interpolation.Route.Heating.furnace)) {
    //        Method.post
    //        Path { HeatingKey.furnace.key }
    //        Body(
    //          .json(
    //            ServerRoute.Api.Route.Interpolation.Route.Heating.Furnace.self,
    //            decoder: self.decoder,
    //            encoder: self.encoder
    //          )
    //        )
    //      }
    //
    //      Route(.case(ServerRoute.Api.Route.Interpolation.Route.Heating.heatPump)) {
    //        Method.post
    //        Path { HeatingKey.heatPump.key }
    //        Body(
    //          .json(
    //            ServerRoute.Api.Route.Interpolation.Route.Heating.HeatPump.self,
    //            decoder: self.decoder,
    //            encoder: self.encoder
    //          )
    //        )
    //      }
    //    }

    //    let interpolationRouter = OneOf {
    //      Route(
    //      Route(.case(ServerRoute.Api.Route.Interpolation.Route.cooling)) {
    //        Path { InterpolationKey.cooling.key }
    //        coolingInterpolationRouter
    //      }
    //
    //      Route(.case(ServerRoute.Api.Route.Interpolation.Route.heating)) {
    //        Path { InterpolationKey.heating.key }
    //        heatingInterpolationRouter
    //      }
    //    }

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
        //        interpolationRouter
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
