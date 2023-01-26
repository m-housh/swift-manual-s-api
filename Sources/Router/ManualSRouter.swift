import ManualSClient
import Models
import URLRouting

public enum ManualSRoute: Equatable {
  
  case api(Api)
  case home
  
  public enum Api: Equatable {
    case derating(ManualSClient.DeratingRequest)
    case interpolate(ManualSClient.InterpolationRequest)
    case requiredKW(ManualSClient.RequiredKWRequest)
    case sizingLimits(SystemType, HouseLoad?)
  }
}


let apiRouter = OneOf {
  Route(.case(ManualSRoute.Api.derating)) {
    Method.post
    Path { "derating" }
    Body(.json(ManualSClient.DeratingRequest.self))
  }
  
  Route(.case(ManualSRoute.Api.interpolate)) {
    Method.post
    Path { "interpolate" }
    Body(.json(ManualSClient.InterpolationRequest.self))
  }
  
  Route(.case(ManualSRoute.Api.requiredKW)) {
    Method.post
    Path { "requiredKw" }
    Body(.json(ManualSClient.RequiredKWRequest.self))
  }
  
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
