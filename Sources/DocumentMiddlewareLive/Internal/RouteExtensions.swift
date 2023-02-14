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
    case .derating:
      return rawValue.capitalized
    case .interpolate:
      return "Interpolations"
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
      return .documentation(.api(.interpolate(.home)))
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
      return "Interpolations"
    case .cooling, .heating:
      return rawValue.capitalized
    }
  }

  var route: ServerRoute {
    switch self {
    case .home:
      return .documentation(.api(.interpolate(.home)))

    case .cooling:
      // fix needs a home route??
      return .documentation(.api(.interpolate(.cooling(.noInterpolation))))
    case .heating:
      // fix needs a home route??
      return .documentation(.api(.interpolate(.heating(.boiler))))
    }
  }
}

extension ServerRoute.Documentation.Route.Interpolation.Cooling: LinkRepresentable {

  var text: String {
    switch self {
    case .noInterpolation:
      return "No Interpolation"
    case .oneWayIndoor:
      return "One Way Indoor"
    case .oneWayOutdoor:
      return "One Way Outdoor"
    case .twoWay:
      return "Two Way"
    }
  }

  var route: ServerRoute {
    switch self {
    case .noInterpolation:
      return .documentation(.api(.interpolate(.cooling(.noInterpolation))))
    case .oneWayIndoor:
      return .documentation(.api(.interpolate(.cooling(.oneWayIndoor))))
    case .oneWayOutdoor:
      return .documentation(.api(.interpolate(.cooling(.oneWayOutdoor))))
    case .twoWay:
      return .documentation(.api(.interpolate(.cooling(.twoWay))))
    }
  }
}

extension ServerRoute.Documentation.Route.Interpolation.Heating: LinkRepresentable {

  var text: String {
    switch self {
    case .boiler:
      return "Boiler"
    case .electric:
      return "Electric"
    case .furnace:
      return "Furnace"
    case .heatPump:
      return "Heat Pump"
    }
  }

  var route: ServerRoute {
    switch self {
    case .boiler:
      return .documentation(.api(.interpolate(.heating(.boiler))))
    case .electric:
      return .documentation(.api(.interpolate(.heating(.electric))))
    case .furnace:
      return .documentation(.api(.interpolate(.heating(.furnace))))
    case .heatPump:
      return .documentation(.api(.interpolate(.heating(.heatPump))))
    }
  }
}
