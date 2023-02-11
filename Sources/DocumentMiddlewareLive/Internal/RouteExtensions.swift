import Models

extension ServerRoute.Documentation.Key: LinkRepresentable {
  var text: String {
    "Documentation"
  }
  var route: Models.ServerRoute {
    .documentation(.home)
  }
}

extension ServerRoute.Documentation.Route.Key: LinkRepresentable {
  var text: String {
    switch self {
    case .balancePoint:
      return "Balance Point"
    case .derating, .interpolate:
      return rawValue.capitalized
    case .requiredKW:
      return "Required KW"
    case .sizingLimits:
      return "Sizing Limits"
    }
  }
  
  var route: Models.ServerRoute {
    switch self {
    case .balancePoint:
      return .documentation(.api(.balancePoint))
    case .derating:
      return .documentation(.api(.derating))
    case .interpolate:
      return .documentation(.api(.interpolate(.cooling(.noInterpolation)))) // fix
    case .requiredKW:
      return .documentation(.api(.requiredKW))
    case .sizingLimits:
      return .documentation(.api(.sizingLimits))
    }
  }
}

extension ServerRoute.Documentation.Route.Interpolation.Key: LinkRepresentable {
  
  var text: String {
    switch self {
    case .home:
      return "Interpolate"
    case .cooling, .heating:
      return rawValue.capitalized
    }
  }
  
  var route: ServerRoute {
    switch self {
    case .home:
      return .documentation(.api(.interpolate(.home)))
      
    case .cooling:
      // fix
      return .documentation(.api(.interpolate(.cooling(.noInterpolation))))
    case .heating:
      // fix
      return .documentation(.api(.interpolate(.heating(.boiler))))
    }
  }
}
