import ArgumentParser
import ClientConfig
import Dependencies
import FileClient
import FirstPartyMocks
import Foundation
import LoggingDependency
import Models
import ValidationMiddleware

extension EquipmentSelection {

  struct Validate: AsyncParsableCommand {
    static let configuration: CommandConfiguration = .init(
      abstract: "Validate a file / template."
    )

    @Flag(help: "The file / template type to validate.")
    var key: Models.Template.PathKey = .project

    @Argument(
      help: """
        The optional input file to validate, if not supplied we will
        search using the default filename for the given key.
        """,
      transform: URL.init(fileURLWithPath:)
    )
    var inputFile: URL?

    @OptionGroup
    var globalOptions: GlobalOptions

    func run() async throws {
      try await CliContext(
        globalOptions: globalOptions,
        run: Run(command: self).run
      )
      .run()
    }
  }
}

extension EquipmentSelection.Validate {
  fileprivate struct Run {
    @Dependency(\.configClient) var configClient
    @Dependency(\.fileClient) var fileClient
    @Dependency(\.jsonCoders.jsonDecoder) var jsonDecoder
    @Dependency(\.logger) var logger
    @Dependency(\.validationMiddleware) var validationMiddleware

    let command: EquipmentSelection.Validate

    func run() async throws {
      let config = await configClient.config()
      let url = config.templatePaths.parseUrl(
        url: command.inputFile,
        with: command.key
      )
      let data = try await fileClient.read(from: url)

      // Handle non embeddable key routes.
      guard let embeddableKey = command.key.embeddableKey else {
        // we are either a project or base interpolation, so handle differently.
        switch command.key {
        case .baseInterpolation:
          _ = try jsonDecoder.decode(Models.Template.BaseInterpolation.self, from: data)
          logger.info("Valid")
          break
        case .project:
          let project = try jsonDecoder.decode(Models.Template.Project.self, from: data)
          try await validate(interpolation: project.interpolation)
          logger.info("Valid")
        // Keep here encase other path keys are added, they must be handled.
        case .boiler,
          .electric,
          .furnace,
          .heatPump,
          .keyed,
          .noInterpolation,
          .oneWayIndoor,
          .oneWayOutdoor,
          .twoWay:
          logger.debug("Invalid key: \(command.key)")
          break
        }
        return
      }
      // Handle embeddable key routes as an interpolation.
      let interpolation = try decodeEmbeddableKey(key: embeddableKey, from: data)
      try await validate(interpolation: interpolation)
      logger.info("Valid")
    }

    func decodeEmbeddableKey(
      key: Models.Template.EmbeddableKey,
      from data: Data
    ) throws -> ServerRoute.Api.Route.Interpolation {
      do {
        let route: ServerRoute.Api.Route.Interpolation.Route
        switch key {
        case .boiler:
          let type = ServerRoute.Api.Route.Interpolation.Route.Heating.Boiler.self
          let boiler = try jsonDecoder.decode(type, from: data)
          route = .heating(route: .boiler(boiler))
        case .electric:
          let type = ServerRoute.Api.Route.Interpolation.Route.Heating.Electric.self
          let model = try jsonDecoder.decode(type, from: data)
          route = .heating(route: .electric(model))
        case .furnace:
          let type = ServerRoute.Api.Route.Interpolation.Route.Heating.Furnace.self
          let model = try jsonDecoder.decode(type, from: data)
          route = .heating(route: .furnace(model))
        case .heatPump:
          let type = ServerRoute.Api.Route.Interpolation.Route.Heating.HeatPump.self
          let model = try jsonDecoder.decode(type, from: data)
          route = .heating(route: .heatPump(model))
        case .keyed:
          let type = [ServerRoute.Api.Route.Interpolation.Route.Keyed].self
          let model = try jsonDecoder.decode(type, from: data)
          route = .keyed(model)
        case .noInterpolation:
          let type = ServerRoute.Api.Route.Interpolation.Route.Cooling.NoInterpolation.self
          let model = try jsonDecoder.decode(type, from: data)
          route = .cooling(route: .noInterpolation(model))
        case .oneWayIndoor:
          let type = ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay.self
          let model = try jsonDecoder.decode(type, from: data)
          route = .cooling(route: .oneWayIndoor(.init(model)))
        case .oneWayOutdoor:
          let type = ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay.self
          let model = try jsonDecoder.decode(type, from: data)
          route = .cooling(route: .oneWayOutdoor(.init(model)))
        case .twoWay:
          let type = ServerRoute.Api.Route.Interpolation.Route.Cooling.TwoWay.self
          let model = try jsonDecoder.decode(type, from: data)
          route = .cooling(route: .twoWay(model))
        }
        return .init(
          designInfo: .mock,
          houseLoad: .mock,
          route: route
        )
      } catch {
        logger.info("Failed:")
        logger.info("\(error)")
        throw error
      }
    }

    func validate(interpolation: ServerRoute.Api.Route.Interpolation) async throws {
      do {
        try await validationMiddleware.validate(
          .api(.init(isDebug: true, route: .interpolate(interpolation)))
        )
        logger.info("Valid")
      } catch {
        logger.info("Failed:")
        logger.info("\(error)")
        throw error
      }
    }
  }
}
