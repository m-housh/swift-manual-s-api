import ApiClient
@_exported import CliMiddleware
import Dependencies
import FileClient
import FirstPartyMocks
import Foundation
import Models
import UserDefaultsClient

struct FixMeError: Error {}

extension CliMiddleware: DependencyKey {

  public static func live(//    baseUrl defaultBaseUrl: URL = URL(string: "http://localhost:8080")!
    ) -> Self
  {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.fileClient) var fileClient
    @Dependency(\.userDefaults) var userDefaults

    return .init(
      baseUrl: {
        userDefaults.url(forKey: .apiBaseUrl)
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
        try await fileClient.read(from: fileUrl)
      },
      setBaseUrl: { baseUrl in
        userDefaults.setUrl(baseUrl, forKey: .apiBaseUrl)
        await apiClient.setBaseUrl(baseUrl)
      },
      template: { interpolation in
        try interpolation.template()
      },
      writeFile: { data, fileUrl in
        try await fileClient.write(data: data, to: fileUrl)
      }
    )
  }

  public static var liveValue: CliMiddleware {
    .live()
  }
}

private let jsonEncoder: JSONEncoder = {
  let encoder = JSONEncoder()
  encoder.outputFormatting = [.prettyPrinted]
  return encoder
}()

extension CliMiddleware.InterpolationName {

  // TODO: Allow templates to be embeded in an interpolation?
  //       currently, only keyed is embedded.
  fileprivate func template() throws -> Data {
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
