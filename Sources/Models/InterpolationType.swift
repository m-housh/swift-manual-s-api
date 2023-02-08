///// Represents the different interpolation types for manufacturer's capacities.
//public enum InterpolationType: CaseIterable, Codable, Equatable, Sendable {
//  case oneWayIndoor
//  case oneWayOutdoor
//  case twoWay
//  case none
//}
//
//extension InterpolationType {
//
//  public var detailedDescription: String {
//    switch self {
//    case .oneWayIndoor:
//      return "For one way interpolation of manufacturer's cooling capacities at indoor design conditions"
//    case .oneWayOutdoor:
//      return "For one way interpolation of manufacturer's cooling capacities at outdoor design conditions"
//    case .twoWay:
//      return "For two way interpolation of manufacturer's cooling capacities at indoor and outdoor design conditions"
//    case .none:
//      return "For no interpolation of manufacturer's cooling capacities at outdoor design conditions"
//    }
//  }
//
//  public var example: String {
//    switch self {
//    case .oneWayIndoor:
//      return """
//      Example: My summer outdoor design is 95° dry-bulb and my indoor design is 63° wet-bulb.
//      The manufacturer's published outdoor data is equal to the design conditions.
//      The manufacturer's published indoor data is 67° and 62° wet-bulb, so interpolation is needed to calculate the capacity at 63° wet-bulb.
//      """
//    case .oneWayOutdoor:
//      return """
//      Example: My summer outdoor design is 92° dry-bulb and my indoor design is 63° wet-bulb.
//      The manufacturer's published outdoor data is 85° and 95° dry-bulb, so interpolation is needed to calculate the capacity at 92° dry-bulb.
//      The manufacturer's published indoor data is equal to the design conditions.
//      """
//    case .twoWay:
//      return """
//      Example: My summer outdoor design is 92° dry-bulb and my indoor design is 63° wet-bulb.
//      The manufacturer's published outdoor data is 85° and 95° dry-bulb so interpolation is needed to calculate the capacity at 92° dry-bulb.
//      The manufacturer's published indoor data is 67° and 62° wet-bulb so interpolation is needed to calculate the capacity at 63° wet-bulb.
//      """
//    case .none:
//      return """
//      Example: My summer outdoor design is 95° dry-bulb and my indoor design is 63° wet-bulb.
//      The manufacturer's published outdoor data is equal to the design conditions.
//      The manufacturer's published indoor data is equal to the design conditions.
//      """
//    }
//  }
//}
//
