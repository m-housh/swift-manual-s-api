import ManualSClient
import Models
import URLRouting

public enum ManualSRouter: Equatable {
  
  case api(Api)
  
  public enum Api: Equatable {
    case derating(ManualSClient.DeratingRequest)
    case interpolate(ManualSClient.InterpolationRequest)
    case requiredKW(ManualSClient.RequiredKWRequest)
    case sizingLimits(SystemType, HouseLoad?)
  }
}


let apiRouter = OneOf {
  Route(.case(ManualSRouter.Api.derating)) {
    Method.post
    Path { "derating" }
    Body(.json(ManualSClient.DeratingRequest.self))
  }
  
  Route(.case(ManualSRouter.Api.interpolate)) {
    Method.post
    Path { "interpolate" }
    Body(.json(ManualSClient.InterpolationRequest.self))
  }
  
  Route(.case(ManualSRouter.Api.requiredKW)) {
    Method.post
    Path { "required-kw" }
    Body(.json(ManualSClient.RequiredKWRequest.self))
  }
  
//  Route(.case(ManualSRouter.Api.sizingLimits)) {
//    Method.post
//    Path { "sizing-limits" }
////    Body(.json(ManualSClient.self))
//  }
}

public let manualSRouter = OneOf {
  Route(.case(ManualSRouter.api)) {
    Path { "api" }
    apiRouter
  }
}
