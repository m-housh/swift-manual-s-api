import CliMiddleware
import Dependencies
import FileClient
import FirstPartyMocks
import Foundation
import JsonDependency
import Models
import SettingsClient
import ValidationMiddleware

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension CliMiddleware.ValidationContext {

  @Sendable
  static func run(context: Self) async throws {
    try await Run(context: context).run()
  }
}

extension CliMiddleware.ValidationContext {
  fileprivate struct Run {
    @Dependency(\.settingsClient) var configClient
    @Dependency(\.fileClient) var fileClient
    @Dependency(\.json.jsonDecoder) var jsonDecoder
    @Dependency(\.logger) var logger
    @Dependency(\.validationMiddleware) var validationMiddleware

    let context: CliMiddleware.ValidationContext

    func run() async throws {
      let config = await configClient.settings()
      let url = config.templatePaths.parseUrl(
        url: context.inputFile,
        with: context.key
      )
      let data = try await fileClient.read(from: url)

      // Handle non embeddable key routes.
      guard let embeddableKey = context.key.embeddableKey else {
        // we are either a project or base interpolation, so handle differently.
        switch context.key {
        case .baseInterpolation:
          _ = try jsonDecoder.decode(Models.Template.BaseInterpolation.self, from: data)
          break
        case .project:
          let project = try jsonDecoder.decode(Project.self, from: data)
          try await validate(project: project)
          break
        // Keep here encase other path keys are added, they must be handled.
        case .boiler,
          .electric,
          .furnace,
          .heatPump,
          .noInterpolation,
          .oneWayIndoor,
          .oneWayOutdoor,
          .twoWay:
          logger.debug("Invalid key: \(context.key)")
          break
        }
        return
      }
      // Handle embeddable key routes as an interpolation.
      let interpolation = try decodeEmbeddableKey(key: embeddableKey, from: data)
      try await validate(interpolation: interpolation)
    }

    func decodeEmbeddableKey(
      key: Models.Template.EmbeddableKey,
      from data: Data
    ) throws -> ServerRoute.Api.Route.Interpolation.Single {
      do {
        let route: ServerRoute.Api.Route.Interpolation.Single.Route
        switch key {
        case .boiler:
          let type = ServerRoute.Api.Route.Interpolation.Single.Route.Heating.Boiler
            .self
          let boiler = try jsonDecoder.decode(type, from: data)
          route = .heating(route: .boiler(boiler))
        case .electric:
          let type = ServerRoute.Api.Route.Interpolation.Single.Route.Heating.Electric
            .self
          let model = try jsonDecoder.decode(type, from: data)
          route = .heating(route: .electric(model))
        case .furnace:
          let type = ServerRoute.Api.Route.Interpolation.Single.Route.Heating.Furnace
            .self
          let model = try jsonDecoder.decode(type, from: data)
          route = .heating(route: .furnace(model))
        case .heatPump:
          let type = ServerRoute.Api.Route.Interpolation.Single.Route.Heating.HeatPump
            .self
          let model = try jsonDecoder.decode(type, from: data)
          route = .heating(route: .heatPump(model))
        case .noInterpolation:
          let type = ServerRoute.Api.Route.Interpolation.Single.Route.Cooling
            .NoInterpolation.self
          let model = try jsonDecoder.decode(type, from: data)
          route = .cooling(route: .noInterpolation(model))
        case .oneWayIndoor:
          let type = ServerRoute.Api.Route.Interpolation.Single.Route.Cooling.OneWay
            .self
          let model = try jsonDecoder.decode(type, from: data)
          route = .cooling(route: .oneWayIndoor(.init(model)))
        case .oneWayOutdoor:
          let type = ServerRoute.Api.Route.Interpolation.Single.Route.Cooling.OneWay
            .self
          let model = try jsonDecoder.decode(type, from: data)
          route = .cooling(route: .oneWayOutdoor(.init(model)))
        case .twoWay:
          let type = ServerRoute.Api.Route.Interpolation.Single.Route.Cooling.TwoWay
            .self
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

    func validate(project: Project) async throws {
      do {
        try await validationMiddleware.validate(
          .api(.init(isDebug: true, route: .interpolate(.project(project))))
        )
        logger.info("Valid")
      } catch {
        logger.info("Failed:")
        logger.info("\(error)")
        throw error
      }
    }

    func validate(interpolation: ServerRoute.Api.Route.Interpolation.Single) async throws {
      do {
        try await validationMiddleware.validate(
          .api(.init(isDebug: true, route: .interpolate(.single(interpolation))))
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
