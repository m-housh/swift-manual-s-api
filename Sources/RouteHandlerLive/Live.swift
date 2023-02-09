import Dependencies
import Models
@_exported import RouteHandler

extension ApiHandler {

  public static let live = Self.init(
    balancePoint: { try await $0.respond() },
    derating: { try await $0.respond() },
    interpolate: { request in
      switch request {
      case let .cooling(coolingRequest):
        return .cooling(try await coolingRequest.respond())
      case let .heating(heatingRequest):
        return .heating(try await heatingRequest.respond())
      }
    },
    requiredKW: { try await $0.respond() },
    sizingLimits: { try await $0.respond() }
  )
}

extension RouteHandler: DependencyKey {
  public static let liveValue: RouteHandler = Self.init(api: .live)
}
