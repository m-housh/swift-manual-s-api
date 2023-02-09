import Dependencies
import Foundation
import Models
import URLRouting

public struct SiteRouter: ParserPrinter {

  public var encoder: JSONEncoder
  public var decoder: JSONDecoder

  public init(
    decoder: JSONDecoder,
    encoder: JSONEncoder
  ) {
    self.encoder = encoder
    self.decoder = decoder
  }

  @ParserBuilder
  public var body: AnyParserPrinter<URLRequestData, ServerRoute> {

    let coolingInterpolationRouter = OneOf {
      Route(.case(ServerRoute.Api.Route.InterpolationRequest.Cooling.noInterpolation)) {
        Method.post
        Path { "noInterpolation" }
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
        Path { "oneWayIndoor" }
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
        Path { "oneWayOutdoor" }
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
        Path { "twoWay" }
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
        Path { "boiler" }
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
        Path { "electric" }
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
        Path { "furnace" }
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
        Path { "heatPump" }
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
        Path { "cooling" }
        coolingInterpolationRouter
      }

      Route(.case(ServerRoute.Api.Route.InterpolationRequest.heating)) {
        Path { "heating" }
        heatingInterpolationRouter
      }
    }

    let apiRouter = OneOf {
      Route(.case(ServerRoute.Api.Route.balancePoint)) {
        Method.post
        Path { "balancePoint" }
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
        Path { "derating" }
        Body(
          .json(
            ServerRoute.Api.Route.DeratingRequest.self,
            decoder: self.decoder,
            encoder: self.encoder
          )
        )
      }

      Route(.case(ServerRoute.Api.Route.interpolate)) {
        Path { "interpolate" }
        interpolationRouter
      }

      Route(.case(ServerRoute.Api.Route.requiredKW)) {
        Method.post
        Path { "requiredKW" }
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
        Path { "sizingLimits" }
        Body(
          .json(
            ServerRoute.Api.Route.SizingLimitRequest.self,
            decoder: decoder,
            encoder: encoder
          )
        )
      }
    }

    OneOf {
      Route(.case(ServerRoute.home))

      Route(.case(ServerRoute.api)) {
        Path { "api" }
        Parse(.memberwise(ServerRoute.Api.init(isDebug:route:))) {
          Headers {
            Field("X-DEBUG", default: false) { Bool.parser() }
          }
          apiRouter
        }
      }
    }
    .eraseToAnyParserPrinter()

  }

  public func print(
    _ output: Models.ServerRoute,
    into input: inout URLRouting.URLRequestData
  ) throws {
    try self.body.print(output, into: &input)
  }

  public func parse(
    _ input: inout URLRouting.URLRequestData
  ) throws -> Models.ServerRoute {
    try self.body.parse(&input)
  }
}

extension SiteRouter: DependencyKey {

  public static var testValue: SiteRouter {
    .init(decoder: .init(), encoder: jsonEncoder)
  }

  public static var liveValue: SiteRouter {
    .init(decoder: .init(), encoder: jsonEncoder)
  }
}

extension DependencyValues {

  public var siteRouter: SiteRouter {
    get { self[SiteRouter.self] }
    set { self[SiteRouter.self] = newValue }
  }
}

private let jsonEncoder: JSONEncoder = {
  var encoder = JSONEncoder()
  encoder.outputFormatting = .sortedKeys
  return encoder
}()
