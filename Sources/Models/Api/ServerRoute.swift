import Foundation

/// Represents the routes for the server.
public enum ServerRoute: Equatable, Sendable {

  /// Api routes.
  case api(Api)

  /// HTML document routes.
  case documentation(Documentation)

  /// The server root.
  case home
}

// MARK: - Documentation Routes
extension ServerRoute {

  /// Represents HTML document routes.
  public enum Documentation: Equatable, Sendable {

    /// The root for documents.
    case home

    /// The api documentation routes.
    case api(Route)

    /// Represents the api routes.
    public enum Route: Equatable, Sendable {
      case balancePoint
      case derating
      case interpolate(Interpolation)
      case requiredKW
      case sizingLimits

      public enum Interpolation: Equatable, Sendable {

        case home
        case cooling(Cooling)
        case heating(Heating)

        public enum Cooling: String, Equatable, Sendable {
          case noInterpolation
          case oneWayIndoor
          case oneWayOutdoor
          case twoWay
        }

        public enum Heating: String, Equatable, Sendable {
          case boiler
          case electric
          case furnace
          case heatPump
        }
      }
    }
  }
}

// MARK: - Api Routes
extension ServerRoute {

  /// Represents api routes / operations that the server can handle.
  public struct Api: Equatable, Sendable {

    /// Is the route in debug mode
    // This is for future use, not really used for anything currently.
    public let isDebug: Bool

    /// The actual api route.
    public let route: Route

    /// Create a new api instance.
    ///
    /// - Parameters:
    ///   - isDebug: Whether the route is in debug mode or not.
    ///   - route: The api route.
    public init(
      isDebug: Bool,
      route: Route
    ) {
      self.isDebug = isDebug
      self.route = route
    }

    /// Represents the api routes and the input types that they handle.
    public enum Route: Equatable, Sendable {

      /// A route that calculates the balance point.
      case balancePoint(BalancePointRequest)

      /// A route that calculates an applicable derating adjustment.
      case derating(DeratingRequest)

      /// A route that interpolates equipment capacities.
      case interpolate(InterpolationRequest)

      /// A  route that calculates the required kilowatt sizing.
      case requiredKW(RequiredKWRequest)

      /// A route that can calculate the allowable sizing limits.
      case sizingLimits(SizingLimitRequest)

      /// Represents the balance point requests we can calculate.
      public enum BalancePointRequest: Codable, Equatable, Sendable {

        /// A route that can calculate the thermal balance point.
        case thermal(Thermal)

        /// The inputs for a thermal balance point request.
        public struct Thermal: Codable, Equatable, Sendable {

          /// The winter outdoor design temperature.
          public var designTemperature: Double

          /// The winter heat loss / load.
          public var heatLoss: Double

          /// The heat pump's capacity at AHRI conditions.
          public var capacity: HeatPumpCapacity

          /// Create a new thermal balance point request.
          ///
          /// - Parameters:
          ///   - designTemperature: The outdoor winter design temperature.
          ///   - heatLoss: The winter heat loss / load of the house.
          ///   - capacity: The heat pump capacity at AHRI conditions.
          public init(designTemperature: Double, heatLoss: Double, capacity: HeatPumpCapacity) {
            self.designTemperature = designTemperature
            self.heatLoss = heatLoss
            self.capacity = capacity
          }
        }
      }

      /// Represents the inputs needed for calculating a derating based on the project elevation.
      ///
      public struct DeratingRequest: Codable, Equatable, Sendable {

        /// The project elevation.
        public var elevation: Int

        /// The  system type to be used.
        public var systemType: SystemType

        /// Create a new derating request.
        ///
        /// - Parameters:
        ///   - elevation: The project elevation.
        ///   - systemType: The system type to be used for the calculation.
        public init(elevation: Int, systemType: SystemType) {
          self.elevation = elevation
          self.systemType = systemType
        }
      }

      /// Represents the inputs need for a required killowatt request.
      ///
      ///
      public struct RequiredKWRequest: Codable, Equatable, Sendable {

        /// The heat pump's capacity at the winter outdoor design temperature, if applicable.
        public var capacityAtDesign: Double?

        /// The buildings winter heat loss / load.
        public var heatLoss: Double

        /// Create a new request.
        ///
        /// - Parameters:
        ///   - capacityAtDesign: The heat pump's capacity at the winter design temperature, if applicable.
        ///   - heatLoss: The buildings winter heat loss / load.
        public init(capacityAtDesign: Double? = nil, heatLoss: Double) {
          self.capacityAtDesign = capacityAtDesign
          self.heatLoss = heatLoss
        }
      }

      /// Represents the inputs needed for sizing limit requests.
      public struct SizingLimitRequest: Codable, Equatable, Sendable {

        /// The system type used.
        public var systemType: SystemType

        /// The house load, which is required for certain climate types (cold-winter or no latent load climates)
        public var houseLoad: HouseLoad?

        /// Create a new sizing limit request.
        ///
        /// - Parameters:
        ///   - systemType: The system type to be used.
        ///   - houseLoad: The house load, if applicable for the climate type.
        public init(systemType: SystemType, houseLoad: HouseLoad? = nil) {
          self.systemType = systemType
          self.houseLoad = houseLoad
        }
      }

      // TODO: Allow an indirect case that interpolates a heating & cooling type during a single request.
      /// Represents the different interpolation requests that can be performed.
      ///
      public enum InterpolationRequest: Codable, Equatable, Sendable {

        /// A cooling interpolation.
        case cooling(Cooling)

        /// A heating interpolation.
        case heating(Heating)

        /// Represents the cooling interpolations that can be performed.
        public enum Cooling: Codable, Equatable, Sendable {

          /// Used when there is no interpolation of the manufacturer's data required.
          ///
          /// This is equivalent to `Form S-1d`.
          case noInterpolation(NoInterpolationRequest)

          /// Used when there is a one way interpolation of the manufacturer's cooling capacity at indoor design conditions.
          ///
          /// This is equivalent to `Form S-1b`
          case oneWayIndoor(OneWayRequest)

          /// Used when there is a one way interpolation of the manufacturer's cooling capacity at outdoor design conditions.
          ///
          /// This is equivalent to `Form S-1b`
          case oneWayOutdoor(OneWayRequest)

          /// Used when there is two way interpolation of the manufacturer's cooling capacity at outdoor and indoor design conditions.
          ///
          /// This is equivalent to `Form S-1a`
          case twoWay(TwoWayRequest)

          public struct TwoWayRequest: CoolingInterpolationRequest {
            public var aboveDesign: CapacityEnvelope
            public var belowDesign: CapacityEnvelope
            public var designInfo: DesignInfo
            public var houseLoad: HouseLoad
            public var manufacturerAdjustments: AdjustmentMultiplier?
            public var systemType: SystemType

            public init(
              aboveDesign: CapacityEnvelope,
              belowDesign: CapacityEnvelope,
              designInfo: DesignInfo,
              houseLoad: HouseLoad,
              manufacturerAdjustments: AdjustmentMultiplier? = nil,
              systemType: SystemType
            ) {
              self.aboveDesign = aboveDesign
              self.belowDesign = belowDesign
              self.designInfo = designInfo
              self.houseLoad = houseLoad
              self.manufacturerAdjustments = manufacturerAdjustments
              self.systemType = systemType
            }

            public struct CapacityEnvelope: Codable, Equatable, Sendable {
              public var aboveWetBulb: ManufactuerCoolingCapacity
              public var belowWetBulb: ManufactuerCoolingCapacity

              public init(
                aboveWetBulb: ManufactuerCoolingCapacity, belowWetBulb: ManufactuerCoolingCapacity
              ) {
                self.aboveWetBulb = aboveWetBulb
                self.belowWetBulb = belowWetBulb
              }
            }
          }

          public struct OneWayRequest: CoolingInterpolationRequest {
            public var aboveDesign: ManufactuerCoolingCapacity
            public var belowDesign: ManufactuerCoolingCapacity
            public var designInfo: DesignInfo
            public var houseLoad: HouseLoad
            public var manufacturerAdjustments: AdjustmentMultiplier?
            public var systemType: SystemType

            public init(
              aboveDesign: ManufactuerCoolingCapacity,
              belowDesign: ManufactuerCoolingCapacity,
              designInfo: DesignInfo,
              houseLoad: HouseLoad,
              manufacturerAdjustments: AdjustmentMultiplier? = nil,
              systemType: SystemType
            ) {
              self.aboveDesign = aboveDesign
              self.belowDesign = belowDesign
              self.designInfo = designInfo
              self.houseLoad = houseLoad
              self.manufacturerAdjustments = manufacturerAdjustments
              self.systemType = systemType
            }
          }

          public struct NoInterpolationRequest: CoolingInterpolationRequest {
            public var capacity: ManufactuerCoolingCapacity
            public var designInfo: DesignInfo
            public var houseLoad: HouseLoad
            public var manufacturerAdjustments: AdjustmentMultiplier?
            public var systemType: SystemType

            public init(
              capacity: ManufactuerCoolingCapacity,
              designInfo: DesignInfo,
              houseLoad: HouseLoad,
              manufacturerAdjustments: AdjustmentMultiplier?,
              systemType: SystemType
            ) {
              self.capacity = capacity
              self.designInfo = designInfo
              self.houseLoad = houseLoad
              self.manufacturerAdjustments = manufacturerAdjustments
              self.systemType = systemType
            }
          }
        }

        public enum Heating: Codable, Equatable, Sendable {

          case boiler(BoilerRequest)
          case electric(ElectricRequest)
          case furnace(FurnaceRequest)
          case heatPump(HeatPumpRequest)

          public struct BoilerRequest: Codable, Equatable, Sendable {
            public var elevation: Int
            public var houseLoad: HouseLoad
            public var input: Int
            public var afue: Double

            public init(
              elevation: Int = 0,
              houseLoad: HouseLoad,
              input: Int,
              afue: Double
            ) {
              self.elevation = elevation
              self.houseLoad = houseLoad
              self.input = input
              self.afue = afue
            }
          }

          public struct ElectricRequest: Codable, Equatable, Sendable {
            public var heatPumpCapacity: Int?
            public var houseLoad: HouseLoad
            public var inputKW: Double

            public init(
              heatPumpCapacity: Int? = nil,
              houseLoad: HouseLoad,
              inputKW: Double
            ) {
              self.heatPumpCapacity = heatPumpCapacity
              self.houseLoad = houseLoad
              self.inputKW = inputKW
            }
          }

          public struct FurnaceRequest: Codable, Equatable, Sendable {
            public var elevation: Int
            public var houseLoad: HouseLoad
            public var input: Int
            public var afue: Double

            public init(
              elevation: Int = 0,
              houseLoad: HouseLoad,
              input: Int,
              afue: Double
            ) {
              self.elevation = elevation
              self.houseLoad = houseLoad
              self.input = input
              self.afue = afue
            }
          }

          public struct HeatPumpRequest: Codable, Equatable, Sendable {
            public var capacity: HeatPumpCapacity
            public var designInfo: DesignInfo
            public var houseLoad: HouseLoad
            public var systemType: SystemType

            public init(
              capacity: HeatPumpCapacity,
              designInfo: DesignInfo,
              houseLoad: HouseLoad,
              systemType: SystemType
            ) {
              self.capacity = capacity
              self.designInfo = designInfo
              self.houseLoad = houseLoad
              self.systemType = systemType
            }
          }
        }
      }
    }
  }
}

// MARK: - Helpers

/// A helper protocol to ensure that cooling interpolation requests carry these values.
public protocol CoolingInterpolationRequest: Codable, Equatable, Sendable {
  var designInfo: DesignInfo { get }
  var houseLoad: HouseLoad { get }
  var manufacturerAdjustments: AdjustmentMultiplier? { get }
  var systemType: SystemType { get }
}

// MARK: - Route Keys

/// A helper protocol to return a route key to be used in routers.
public protocol RouteKey: CaseIterable {
  var key: String { get }
}

extension RawRepresentable where RawValue == String, Self: RouteKey {
  public var key: String { rawValue }
}

extension ServerRoute.Documentation.Route.Interpolation.Cooling: RouteKey {}
extension ServerRoute.Documentation.Route.Interpolation.Heating: RouteKey {}

extension ServerRoute.Documentation.Route.Interpolation {
  public enum Key: String, RouteKey {
    case home
    case cooling
    case heating

    public var key: String {
      switch self {
      case .home:
        return "/"
      case .cooling, .heating:
        return rawValue
      }
    }
  }
}

extension ServerRoute.Documentation.Route {
  public enum Key: String, RouteKey {
    case balancePoint
    case derating
    case interpolate
    case requiredKW
    case sizingLimits
  }
}

extension ServerRoute.Documentation {
  public enum Key: String, RouteKey {
    case home
    case api

    public var key: String {
      switch self {
      case .home:
        return "/"
      case .api:
        return rawValue
      }
    }
  }
}

extension ServerRoute {
  public enum Key: String, RouteKey {
    case home
    case documentation
    case api

    public var key: String {
      switch self {
      case .home:
        return "/"
      case .api, .documentation:
        return rawValue
      }
    }
  }
}

// MARK: Custom Encoding

extension ServerRoute.Api.Route.BalancePointRequest {

  private enum CodingKeys: String, CodingKey {
    case thermal
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .thermal(thermal):
      try container.encode(thermal, forKey: .thermal)
    }
  }
}
