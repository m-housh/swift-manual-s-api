import Foundation

/// Represents values for a project.
///
public struct Project: Codable, Equatable, Sendable {

  /// The project / customer information.
  public var projectInfo: ProjectInfo

  /// The project design information.
  public var designInfo: DesignInfo

  /// The project's house load.
  public var houseLoad: HouseLoad

  /// The systems for this project.
  ///
  public var systems: [System]

  /// Create a new ``Project`` instance.
  ///
  /// - Parameters:
  ///   - projectInfo: The customer / project information.
  ///   - designInfo: The design information.
  ///   - houseLoad: The house load.
  ///   - systems: The systems to use in the project.
  public init(
    projectInfo: ProjectInfo,
    designInfo: DesignInfo,
    houseLoad: HouseLoad,
    systems: [System]
  ) {
    self.projectInfo = projectInfo
    self.designInfo = designInfo
    self.houseLoad = houseLoad
    self.systems = systems
  }

  /// Represents the customer / project data.
  ///
  public struct ProjectInfo: Codable, Equatable, Sendable {

    /// The customer / project name.
    public var name: String

    /// The customer address.
    public var address: String

    /// The customer city.
    public var city: String

    /// The customer state.
    public var state: String

    /// The customer zip code.
    public var zipCode: Int

    /// Create a new ``Template/Project/ProjectInfo-swift.struct`` instance.
    ///
    /// - Parameters:
    ///   - name: The customer name.
    ///   - address: The customer address.
    ///   - city: The customer city.
    ///   - state: The customer state.
    ///   - zipCode: The customer zip code.
    public init(
      name: String,
      address: String,
      city: String,
      state: String,
      zipCode: Int
    ) {
      self.name = name
      self.address = address
      self.city = city
      self.state = state
      self.zipCode = zipCode
    }
  }

  public struct System: Codable, Equatable, Sendable {
    public var name: String
    public var systemId: String
    public var systemType: SystemType
    public var cooling: ServerRoute.Api.Route.Interpolation.Single.Route.Cooling
    public var heating: [ServerRoute.Api.Route.Interpolation.Single.Route.Heating]

    public init(
      name: String,
      systemId: String = "systemId",
      systemType: SystemType = .default,
      cooling: ServerRoute.Api.Route.Interpolation.Single.Route.Cooling,
      heating: [ServerRoute.Api.Route.Interpolation.Single.Route.Heating] = []
    ) {
      self.name = name
      self.systemType = systemType
      self.systemId = systemId
      self.cooling = cooling
      self.heating = heating
    }
  }
}

extension Project {

  /// Returns the project as an array of single interpolation values.
  public var interpolations: [ServerRoute.Api.Route.Interpolation.Single] {
    systems.reduce(into: [ServerRoute.Api.Route.Interpolation.Single]()) { result, system in
      result.append(
        .init(
          designInfo: self.designInfo,
          houseLoad: self.houseLoad,
          systemType: system.systemType,
          route: .cooling(route: system.cooling)
        ))

      let heating = system.heating.reduce(into: [ServerRoute.Api.Route.Interpolation.Single]()) {
        result, heating in
        result.append(
          .init(
            designInfo: self.designInfo,
            houseLoad: self.houseLoad,
            systemType: system.systemType,
            route: .heating(route: heating)
          ))
      }

      result += heating
    }
  }
}
