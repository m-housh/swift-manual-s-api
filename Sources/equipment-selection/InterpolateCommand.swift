import ApiClientLive
import ArgumentParser
import Dependencies
import Foundation
import Models

extension EquipmentSelection {
  struct Interpolate: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
      abstract: "Run an interpolation for the input file."
    )

    @Flag var interpolation: InterpolationName

    @Option(name: .shortAndLong, transform: URL.init(fileURLWithPath:))
    var inputPath: URL?

    @Option(name: .shortAndLong, transform: URL.init(fileURLWithPath:))
    var outputPath: URL?

    @Flag var verbose: Bool = false

    func run() async throws {
      print("FIX ME.")
      let path = interpolation.parseUrl(url: inputPath)
      let outputPath = outputPath ?? URL(fileURLWithPath: "./result.json")

      let (route, result) = try await withDependencies {
        $0.apiClient = .live(baseUrl: URL(string: "https://hvacmath.com")!)
      } operation: {
        return try await InterpolateRunner(interpolation: interpolation, inputPath: path).run()
      }

      if verbose {
        print()
        print("Result:")
        print()
        print("\(result)")
      }

      guard case let .interpolate(.cooling(.oneWayIndoor(request))) = route else {
        let data = try jsonEncoder.encode(result)
        try data.write(to: outputPath)
        print("Wrote result to: \(outputPath.absoluteString)")
        return
      }

      guard result.failures == nil else {
        print("Failed:")
        print("\(result.failures!)")
        return
      }

      let template = try OneWayIndoorAnvilTemplate(request: request, result: result.result)
      let (data, _) = try await apiRequest(template)

      // FIX.
      let pdfPath = URL(fileURLWithPath: "./result.pdf")
      try data.write(to: pdfPath)
      print("Done")
    }
  }
}

// Commands need to be decodable, so we need this helper to use the apiClient dependency.

private struct InterpolateRunner {
  @Dependency(\.apiClient) var apiClient

  let interpolation: InterpolationName
  let inputPath: URL

  func run() async throws -> (ServerRoute.Api.Route, InterpolationResponse) {
    // do something.
    let data = try Data(contentsOf: inputPath)
    let route = try interpolation.route(data: data)
    return try await (
      route,
      apiClient.apiRequest(
        route: route,
        as: InterpolationResponse.self
      )
    )
  }
}

extension InterpolationName {
  fileprivate func route(data: Data) throws -> ServerRoute.Api.Route {
    let decoder = JSONDecoder()
    switch self {
    case .boiler:
      return try .interpolate(
        .heating(
          .boiler(
            decoder.decode(
              ServerRoute.Api.Route.Interpolation.Heating.Boiler.self,
              from: data
            )
          )))
    case .electric:
      return try .interpolate(
        .heating(
          .electric(
            decoder.decode(
              ServerRoute.Api.Route.Interpolation.Heating.Electric.self,
              from: data
            )
          )))
    case .furnace:
      return try .interpolate(
        .heating(
          .furnace(
            decoder.decode(
              ServerRoute.Api.Route.Interpolation.Heating.Furnace.self,
              from: data
            )
          )))
    case .heatPump:
      return try .interpolate(
        .heating(
          .heatPump(
            decoder.decode(
              ServerRoute.Api.Route.Interpolation.Heating.HeatPump.self,
              from: data
            )
          )))
    case .noInterpolation:
      return try .interpolate(
        .cooling(
          .noInterpolation(
            decoder.decode(
              ServerRoute.Api.Route.Interpolation.Cooling.NoInterpolation.self,
              from: data
            )
          )))
    case .oneWayIndoor:
      return try .interpolate(
        .cooling(
          .oneWayIndoor(
            decoder.decode(
              ServerRoute.Api.Route.Interpolation.Cooling.OneWay.self,
              from: data
            )
          )))
    case .oneWayOutdoor:
      return try .interpolate(
        .cooling(
          .oneWayOutdoor(
            decoder.decode(
              ServerRoute.Api.Route.Interpolation.Cooling.OneWay.self,
              from: data
            )
          )))
    case .twoWay:
      return try .interpolate(
        .cooling(
          .twoWay(
            decoder.decode(
              ServerRoute.Api.Route.Interpolation.Cooling.TwoWay.self,
              from: data
            )
          )))
    }
  }
}
