@_exported import ApiRouteMiddleware
import Dependencies
import Models

extension ApiRouteMiddleware: DependencyKey {

  public static var liveValue: ApiRouteMiddleware {
    .init(
      balancePoint: { try await $0.respond() },
      derating: { try await $0.respond() },
      interpolate: { request in
//        print("interpolate: \(request)")
        switch request {
        case let .single(single):
//          print("single: \(single)")
          switch single.route {
          case let .cooling(coolingRequest):
            return try await coolingRequest.respond(request: single)
          case let .heating(heatingRequest):
            print("Heating request: \(heatingRequest)")
            return try await heatingRequest.respond(request: single)
          }
        case .project:
          #warning("Fix me.")
          fatalError()
        }
      },
      requiredKW: { try await $0.respond() },
      sizingLimits: { try await $0.respond() }
    )
  }
}
