@_exported import ApiRouteMiddleware
import Dependencies
import Models

extension ApiRouteMiddleware: DependencyKey {

  public static var liveValue: ApiRouteMiddleware {
    .init(
      balancePoint: { try await $0.respond() },
      derating: { try await $0.respond() },
      interpolate: { request in
        switch request {
        case let .cooling(coolingRequest):
          return try await coolingRequest.respond()
        case let .heating(heatingRequest):
          return try await heatingRequest.respond()
        case let .keyed(keyed):
          print("FIX ME: \(keyed)")
          // fix.
          fatalError()
        }
      },
      requiredKW: { try await $0.respond() },
      sizingLimits: { try await $0.respond() }
    )
  }
}
