import ManualSClient
import Models
import URLRouting

public enum ManualSRoute: Equatable {
  
  case api(Api)
  case home
  
  public enum Api: Equatable {
//    case derating(ManualSClient.DeratingRequest)
    case interpolate(ManualSClient.InterpolationRequest)
//    case requiredKW(ManualSClient.RequiredKWRequest)
//    case sizingLimits(SystemType, HouseLoad?)
  }
}


let apiRouter = OneOf {
//  Route(.case(ManualSRoute.Api.derating)) {
//    Method.post
//    Path { "derating" }
//    Body(.json(ManualSClient.DeratingRequest.self))
//  }
//
  Route(.case(ManualSRoute.Api.interpolate)) {
    Method.post
    Path { "interpolate" }
    Body(.json(ManualSClient.InterpolationRequest.self))
  }
  
//  Route(.case(ManualSRoute.Api.requiredKW)) {
//    Method.post
//    Path { "requiredKw" }
//    Body(.json(ManualSClient.RequiredKWRequest.self))
//  }
  
//  Route(.case(ManualSRouter.Api.sizingLimits)) {
//    Method.post
//    Path { "sizing-limits" }
////    Body(.json(ManualSClient.self))
//  }
}

public let manualSRouter = OneOf {
  // root
  Route(.case(ManualSRoute.home))
  
  Route(.case(ManualSRoute.api)) {
    Path { "api" }
    apiRouter
  }
}

let _coolingInterpolationRouter = OneOf {
  Route(.case(ServerRoute.Api.Route.InterpolationRequest.Cooling.noInterpolation)) {
    Method.post
    Path { "noInterpolation" }
    Body(.json(ServerRoute.Api.Route.InterpolationRequest.Cooling.NoInterpolationRequest.self))
  }
  
  Route(.case(ServerRoute.Api.Route.InterpolationRequest.Cooling.oneWayIndoor)) {
    Method.post
    Path { "oneWayIndoor" }
    Body(.json(ServerRoute.Api.Route.InterpolationRequest.Cooling.OneWayRequest.self))
  }
  
  Route(.case(ServerRoute.Api.Route.InterpolationRequest.Cooling.oneWayOutdoor)) {
    Method.post
    Path { "oneWayOutdoor" }
    Body(.json(ServerRoute.Api.Route.InterpolationRequest.Cooling.OneWayRequest.self))
  }
  
  Route(.case(ServerRoute.Api.Route.InterpolationRequest.Cooling.twoWay)) {
    Method.post
    Path { "twoWay" }
    Body(.json(ServerRoute.Api.Route.InterpolationRequest.Cooling.TwoWayRequest.self))
  }
}

let _heatingInterpolationRouter = OneOf {
  Route(.case(ServerRoute.Api.Route.InterpolationRequest.Heating.boiler)) {
    Method.post
    Path { "boiler" }
    Body(.json(ServerRoute.Api.Route.InterpolationRequest.Heating.BoilerRequest.self))
  }
  
  Route(.case(ServerRoute.Api.Route.InterpolationRequest.Heating.electric)) {
    Method.post
    Path { "electric" }
    Body(.json(ServerRoute.Api.Route.InterpolationRequest.Heating.ElectricRequest.self))
  }
  
  Route(.case(ServerRoute.Api.Route.InterpolationRequest.Heating.furnace)) {
    Method.post
    Path { "furnace" }
    Body(.json(ServerRoute.Api.Route.InterpolationRequest.Heating.FurnaceRequest.self))
  }
  
  Route(.case(ServerRoute.Api.Route.InterpolationRequest.Heating.heatPump)) {
    Method.post
    Path { "heatPump" }
    Body(.json(ServerRoute.Api.Route.InterpolationRequest.Heating.HeatPumpRequest.self))
  }
}

let _interpolationRouter = OneOf {
  Route(.case(ServerRoute.Api.Route.InterpolationRequest.cooling)) {
    Path { "cooling" }
    _coolingInterpolationRouter
  }
  
  Route(.case(ServerRoute.Api.Route.InterpolationRequest.heating)) {
    Path { "heating" }
    _heatingInterpolationRouter
  }
}

let _apiRouter = OneOf {
  Route(.case(ServerRoute.Api.Route.balancePoint)) {
    Method.post
    Path { "balancePoint" }
    Body(.json(ServerRoute.Api.Route.BalancePointRequest.self))
  }
  
  Route(.case(ServerRoute.Api.Route.derating)) {
    Method.post
    Path { "derating" }
    Body(.json(ServerRoute.Api.Route.Derating.self))
  }
  
  Route(.case(ServerRoute.Api.Route.interpolate)) {
    Path { "interpolate" }
    _interpolationRouter
  }
  
  Route(.case(ServerRoute.Api.Route.requiredKW)) {
    Method.post
    Path { "requiredKW" }
    Body(.json(ServerRoute.Api.Route.RequiredKW.self))
  }
}
