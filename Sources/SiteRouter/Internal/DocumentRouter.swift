import Models
import URLRouting

// TODO: Move
//enum InterpolationKey: String {
//  case cooling
//  case heating
//}
//
//enum RouteKey: String {
//  case balancePoint
//  case derating
//  case interpolate
//  case requiredKW
//  case sizingLimits
//}

struct DocumentRouter: ParserPrinter {

  //  typealias CoolingKey = ServerRoute.Documentation.Route.Interpolation.Cooling
  //  typealias HeatingKey = ServerRoute.Documentation.Route.Interpolation.Heating

  @ParserBuilder
  var body: AnyParserPrinter<URLRequestData, ServerRoute.Documentation> {
    let coolingInterpolationRouter = OneOf {
      Route(.case(ServerRoute.Documentation.Route.Interpolation.Cooling.noInterpolation)) {
        Method.get
        Path { CoolingKey.noInterpolation.key }
      }

      Route(.case(ServerRoute.Documentation.Route.Interpolation.Cooling.oneWayIndoor)) {
        Method.get
        Path { CoolingKey.oneWayIndoor.key }
      }

      Route(.case(ServerRoute.Documentation.Route.Interpolation.Cooling.oneWayOutdoor)) {
        Method.get
        Path { CoolingKey.oneWayOutdoor.key }
      }

      Route(.case(ServerRoute.Documentation.Route.Interpolation.Cooling.twoWay)) {
        Method.get
        Path { CoolingKey.twoWay.key }
      }
    }

    let heatingInterpolationRouter = OneOf {
      Route(.case(ServerRoute.Documentation.Route.Interpolation.Heating.boiler)) {
        Method.get
        Path { HeatingKey.boiler.key }
      }

      Route(.case(ServerRoute.Documentation.Route.Interpolation.Heating.electric)) {
        Method.get
        Path { HeatingKey.electric.key }
      }

      Route(.case(ServerRoute.Documentation.Route.Interpolation.Heating.furnace)) {
        Method.get
        Path { HeatingKey.furnace.key }
      }

      Route(.case(ServerRoute.Documentation.Route.Interpolation.Heating.heatPump)) {
        Method.get
        Path { HeatingKey.heatPump.key }
      }
    }

    let interpolationRouter = OneOf {

      Route(.case(ServerRoute.Documentation.Route.Interpolation.home))

      Route(.case(ServerRoute.Documentation.Route.Interpolation.cooling)) {
        Path { InterpolationKey.cooling.key }
        coolingInterpolationRouter
      }

      Route(.case(ServerRoute.Documentation.Route.Interpolation.heating)) {
        Path { InterpolationKey.heating.key }
        heatingInterpolationRouter
      }
    }

    let routeRouter = OneOf {
      Route(.case(ServerRoute.Documentation.Route.balancePoint)) {
        Method.get
        Path { RouteKey.balancePoint.key }
      }

      Route(.case(ServerRoute.Documentation.Route.derating)) {
        Method.get
        Path { RouteKey.derating.key }
      }

      Route(.case(ServerRoute.Documentation.Route.interpolate)) {
        Path { RouteKey.interpolate.key }
        interpolationRouter
      }

      Route(.case(ServerRoute.Documentation.Route.requiredKW)) {
        Method.get
        Path { RouteKey.requiredKW.key }
      }

      Route(.case(ServerRoute.Documentation.Route.sizingLimits)) {
        Method.get
        Path { RouteKey.sizingLimits.key }
      }
    }

    OneOf {
      Route(.case(ServerRoute.Documentation.home))

      Route(.case(ServerRoute.Documentation.api)) {
        Path { ServerRoute.Documentation.Key.api.key }
        routeRouter
      }
    }
    .eraseToAnyParserPrinter()

  }

  func parse(
    _ input: inout URLRequestData
  ) throws -> ServerRoute.Documentation {
    try body.parse(&input)
  }

  func print(_ output: ServerRoute.Documentation, into input: inout URLRequestData) throws {
    try body.print(output, into: &input)
  }
}
