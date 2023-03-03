import Foundation
import Tagged

/// Represents the routes for the server.
public enum ServerRoute: Equatable, Sendable {

  // NOTE: Add routes here, you need to handle validations (``ValidationMiddlewareLive``),
  // site router (``SiteRouter``) and site middleware (``SiteMiddlewareLive``).

  /// Api routes.
  case api(Api)

  /// HTML document routes.
  case documentation(Documentation)

  case `public`(Public)

  /// The server root.
  case home

  case favicon

  case siteManifest

  case appleTouchIcon

  case appleTouchIconPrecomposed
}

// MARK: - Documentation Routes
extension ServerRoute {

  /// Represents the public file routes.
  public enum Public: Equatable, Sendable {
    case favicon
    case images(file: String)
    case tools(file: String)
  }

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

      // TODO: Update to new interpolation routes.
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
      case balancePoint(BalancePoint)

      /// A route that calculates an applicable derating adjustment.
      case derating(Derating)

      /// A route that interpolates equipment capacities.
      case interpolate(Interpolation)

      /// A  route that calculates the required kilowatt sizing.
      case requiredKW(RequiredKW)

      /// A route that can calculate the allowable sizing limits.
      case sizingLimits(SizingLimit)

      /// Represents the balance point requests we can calculate.
      public enum BalancePoint: Codable, Equatable, Sendable {

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
      public struct Derating: Codable, Equatable, Sendable {

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
      public struct RequiredKW: Codable, Equatable, Sendable {

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
      public struct SizingLimit: Codable, Equatable, Sendable {

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

      #warning("Create enum for single interpolation vs. project.")
      /// Represents the different interpolation requests that can be performed.
      ///
      public typealias Interpolation = Models._Interpolation
    }
  }
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

// MARK: Coding

extension ServerRoute.Api.Route.BalancePoint {

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

// MARK: - Tags
public enum AboveTag {}
public enum BelowTag {}
public enum IndoorTag {}
public enum OutdoorTag {}

public enum _Interpolation: Codable, Equatable, Sendable {
  // remove system type from being optional on single types.
  case single(Interpolation)
  case project(Project)
  
  // Create a single instance, convenience.
  public init(
    designInfo: DesignInfo,
    houseLoad: HouseLoad,
    systemType: SystemType? = nil,
    route: Interpolation.Route
  ) {
    self = .single(
      .init(
        designInfo: designInfo,
        houseLoad: houseLoad,
        systemType: systemType,
        route: route
      )
    )
  }
  
  // FIX.
  public typealias SingleInterpolation = Models.Interpolation
}
// TODO: - Need cooling and heating interpolations to hold onto optional systemType
//        if they are called stand-alone and not embedded in a keyed interpolation.
public struct Interpolation: Codable, Equatable, Sendable {

  public var designInfo: DesignInfo
  public var houseLoad: HouseLoad
  public var systemType: SystemType?
  public var route: Route

  public init(
    designInfo: DesignInfo,
    houseLoad: HouseLoad,
    systemType: SystemType? = nil,
    route: Route
  ) {
    self.designInfo = designInfo
    self.houseLoad = houseLoad
    self.systemType = systemType
    self.route = route
  }

  public enum Route: Codable, Equatable, Sendable {
    case cooling(route: Cooling)
    case heating(route: Heating)
    // remove.
    case systems([Project.System])

    /// Represents the cooling interpolations that can be performed.
    public enum Cooling: Codable, Equatable, Sendable {

      /// Used when there is no interpolation of the manufacturer's data required.
      ///
      /// This is equivalent to `Form S-1d`.
      case noInterpolation(NoInterpolation)

      /// Used when there is a one way interpolation of the manufacturer's cooling capacity at indoor design conditions.
      ///
      /// This is equivalent to `Form S-1b`
      case oneWayIndoor(Tagged<IndoorTag, OneWay>)

      /// Used when there is a one way interpolation of the manufacturer's cooling capacity at outdoor design conditions.
      ///
      /// This is equivalent to `Form S-1b`
      case oneWayOutdoor(Tagged<OutdoorTag, OneWay>)

      /// Used when there is two way interpolation of the manufacturer's cooling capacity at outdoor and indoor design conditions.
      ///
      /// This is equivalent to `Form S-1a`
      case twoWay(TwoWay)

      /// Used when there is two way interpolation of the manufacturer's cooling capacity at outdoor and indoor design conditions.
      ///
      /// This is equivalent to `Form S-1a`
      public struct TwoWay: Codable, Equatable, Sendable {
        public var aboveDesign: Tagged<AboveTag, CapacityEnvelope>
        public var belowDesign: Tagged<BelowTag, CapacityEnvelope>
        public var manufacturerAdjustments: AdjustmentMultiplier?

        public init(
          aboveDesign: Tagged<AboveTag, CapacityEnvelope>,
          belowDesign: Tagged<BelowTag, CapacityEnvelope>,
          manufacturerAdjustments: AdjustmentMultiplier? = nil
        ) {
          self.aboveDesign = aboveDesign
          self.belowDesign = belowDesign
          self.manufacturerAdjustments = manufacturerAdjustments
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

      public struct OneWay: Codable, Equatable, Sendable {
        public var aboveDesign: ManufactuerCoolingCapacity
        public var belowDesign: ManufactuerCoolingCapacity
        public var manufacturerAdjustments: AdjustmentMultiplier?

        public init(
          aboveDesign: ManufactuerCoolingCapacity,
          belowDesign: ManufactuerCoolingCapacity,
          manufacturerAdjustments: AdjustmentMultiplier? = nil
        ) {
          self.aboveDesign = aboveDesign
          self.belowDesign = belowDesign
          self.manufacturerAdjustments = manufacturerAdjustments
        }
      }

      public struct NoInterpolation: Codable, Equatable, Sendable {
        public var capacity: ManufactuerCoolingCapacity
        public var manufacturerAdjustments: AdjustmentMultiplier?

        public init(
          capacity: ManufactuerCoolingCapacity,
          manufacturerAdjustments: AdjustmentMultiplier?
        ) {
          self.capacity = capacity
          self.manufacturerAdjustments = manufacturerAdjustments
        }
      }
    }

    public enum Heating: Codable, Equatable, Sendable {

      case boiler(Boiler)
      case electric(Electric)
      case furnace(Furnace)
      case heatPump(HeatPump)

      public struct Boiler: Codable, Equatable, Sendable {
        public var input: Int
        public var afue: Double

        public init(
          input: Int,
          afue: Double
        ) {
          self.input = input
          self.afue = afue
        }
      }

      public struct Electric: Codable, Equatable, Sendable {
        public var heatPumpCapacity: Int?
        public var inputKW: Double

        public init(
          heatPumpCapacity: Int? = nil,
          inputKW: Double
        ) {
          self.heatPumpCapacity = heatPumpCapacity
          self.inputKW = inputKW
        }
      }

      public struct Furnace: Codable, Equatable, Sendable {
        public var input: Int
        public var afue: Double

        public init(
          input: Int,
          afue: Double
        ) {
          self.input = input
          self.afue = afue
        }
      }

      public struct HeatPump: Codable, Equatable, Sendable {
        public var capacity: HeatPumpCapacity

        public init(
          capacity: HeatPumpCapacity
        ) {
          self.capacity = capacity
        }
      }
    }
  }
}

// MARK: - Coding
extension Interpolation {

  // Encode in specific order.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(houseLoad, forKey: .houseLoad)
    try container.encode(designInfo, forKey: .designInfo)
    try container.encode(route, forKey: .route)
  }
}

extension Interpolation.Route {
  private enum CodingKeys: CodingKey {
    case cooling
    case heating
    case systems
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .cooling(cooling):
      try container.encode(cooling, forKey: .cooling)
    case let .heating(heating):
      try container.encode(heating, forKey: .heating)
    case let .systems(systems):
      try container.encode(systems, forKey: .systems)
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if let cooling = try? container.decode(Cooling.self, forKey: .cooling) {
      self = .cooling(route: cooling)
    } else if let heating = try? container.decode(Heating.self, forKey: .heating) {
      self = .heating(route: heating)
    } else if let systems = try? container.decode([Project.System].self, forKey: .systems) {
      self = .systems(systems)
    } else {
      throw DecodingError()
    }
  }
}

extension Interpolation.Route.Cooling {

  private enum CodingKeys: CodingKey {
    case noInterpolation
    case oneWayIndoor
    case oneWayOutdoor
    case twoWay
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .noInterpolation(noInterpolation):
      try container.encode(noInterpolation, forKey: .noInterpolation)
    case let .oneWayIndoor(oneWayIndoor):
      try container.encode(oneWayIndoor, forKey: .oneWayIndoor)
    case let .oneWayOutdoor(oneWayOutdoor):
      try container.encode(oneWayOutdoor, forKey: .oneWayOutdoor)
    case let .twoWay(twoWay):
      try container.encode(twoWay, forKey: .twoWay)
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let noInterpolation = try? container.decode(NoInterpolation.self, forKey: .noInterpolation) {
      self = .noInterpolation(noInterpolation)
    } else if let oneWayIndoor = try? container.decode(OneWay.self, forKey: .oneWayIndoor) {
      self = .oneWayIndoor(.init(oneWayIndoor))
    } else if let oneWayOutdoor = try? container.decode(OneWay.self, forKey: .oneWayOutdoor) {
      self = .oneWayOutdoor(.init(oneWayOutdoor))
    } else if let twoWay = try? container.decode(TwoWay.self, forKey: .twoWay) {
      self = .twoWay(twoWay)
    } else {
      throw DecodingError()
    }
  }
}

extension Interpolation.Route.Heating {

  private enum CodingKeys: CodingKey {
    case boiler
    case electric
    case furnace
    case heatPump
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .boiler(boiler):
      try container.encode(boiler, forKey: .boiler)
    case let .electric(electric):
      try container.encode(electric, forKey: .electric)
    case let .furnace(furnace):
      try container.encode(furnace, forKey: .furnace)
    case let .heatPump(heatPump):
      try container.encode(heatPump, forKey: .heatPump)
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let boiler = try? container.decode(Boiler.self, forKey: .boiler) {
      self = .boiler(boiler)
      return
    } else if let electric = try? container.decode(Electric.self, forKey: .electric) {
      self = .electric(electric)
      return
    } else if let furnace = try? container.decode(Furnace.self, forKey: .furnace) {
      self = .furnace(furnace)
      return
    } else if let heatPump = try? container.decode(HeatPump.self, forKey: .heatPump) {
      self = .heatPump(heatPump)
      return
    }
    throw DecodingError()
  }
}

// MARK: - Tagged Extensions
extension Tagged where RawValue == ServerRoute.Api.Route.Interpolation.SingleInterpolation.Route.Cooling.OneWay {
  public init(
    aboveDesign: ManufactuerCoolingCapacity,
    belowDesign: ManufactuerCoolingCapacity,
    manufacturerAdjustments: AdjustmentMultiplier? = nil
  ) {
    self.init(
      .init(
        aboveDesign: aboveDesign,
        belowDesign: belowDesign,
        manufacturerAdjustments: manufacturerAdjustments
      )
    )
  }
}

extension Tagged
where RawValue == ServerRoute.Api.Route.Interpolation.SingleInterpolation.Route.Cooling.TwoWay.CapacityEnvelope {
  public init(
    aboveWetBulb: ManufactuerCoolingCapacity,
    belowWetBulb: ManufactuerCoolingCapacity
  ) {
    self.init(
      .init(
        aboveWetBulb: aboveWetBulb,
        belowWetBulb: belowWetBulb
      ))
  }
}
