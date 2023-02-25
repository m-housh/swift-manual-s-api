import ApiClient
@_exported import CliMiddleware
import Dependencies
import FirstPartyMocks
import Foundation
import Models

struct FixMeError: Error {}

extension CliMiddleware: DependencyKey {

  public static func live(
    baseUrl defaultBaseUrl: URL = URL(string: "http://localhost:8080")!
  ) -> Self {
    @Dependency(\.apiClient) var apiClient

    return .init(
      baseUrl: {
        UserDefaults.standard.url(forKey: baseUrlKey)
          ?? apiClient.baseUrl()
      },
      generatePdf: { _, _ in
        throw FixMeError()
      },
      interpolate: { route in
        try await apiClient.apiRequest(
          route: .interpolate(route),
          as: InterpolationResponse.self
        )
      },
      readFile: { fileUrl in
        try Data(contentsOf: fileUrl)
      },
      setBaseUrl: { baseUrl in
        UserDefaults.standard.set(baseUrl, forKey: baseUrlKey)
        await apiClient.setBaseUrl(baseUrl)
      },
      template: { interpolation in
        try interpolation.template()
      },
      writeFile: { data, fileUrl in
        try data.write(to: fileUrl)
      }
    )
  }

  public static var liveValue: CliMiddleware {
    .live()
  }
}

private let baseUrlKey = "com.hvacmatho.equipment-selection.baseUrl"
private let jsonEncoder: JSONEncoder = {
  let encoder = JSONEncoder()
  encoder.outputFormatting = [.prettyPrinted]
  return encoder
}()

fileprivate extension CliMiddleware.InterpolationName {
  
  // TODO: Allow templates to be embeded in an interpolation?
  //       currently, only keyed is embedded.
  func template() throws -> Data {
    switch self {
    case .boiler:
      return try jsonEncoder.encode(
        ServerRoute.Api.Route.Interpolation.Route.Heating.Boiler.mock
      )
    case .electric:
      return try jsonEncoder.encode(
        ServerRoute.Api.Route.Interpolation.Route.Heating.Electric.mock
      )
    case .furnace:
      return try jsonEncoder.encode(
        ServerRoute.Api.Route.Interpolation.Route.Heating.Furnace.mock
      )
    case .heatPump:
      return try jsonEncoder.encode(
        ServerRoute.Api.Route.Interpolation.Route.Heating.HeatPump.mock
      )
    case .noInterpolation:
      return try jsonEncoder.encode(
        ServerRoute.Api.Route.Interpolation.Route.Cooling.NoInterpolation.mock
      )
    case .oneWayIndoor:
      return try jsonEncoder.encode(
        ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay.indoorMock
      )
    case .oneWayOutdoor:
      return try jsonEncoder.encode(
        ServerRoute.Api.Route.Interpolation.Route.Cooling.OneWay.outdoorMock
      )
    case .twoWay:
      return try jsonEncoder.encode(
        ServerRoute.Api.Route.Interpolation.Route.Cooling.TwoWay.mock
      )
    case .keyed:
      return try jsonEncoder.encode(
        ServerRoute.Api.Route.Interpolation.mock(route: .keyed(.mocks))
      )
    }
  }
}
