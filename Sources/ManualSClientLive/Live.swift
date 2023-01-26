import ManualSClient

extension ManualSClient {
  
  public static let live = Self.init(
    derating: { try await $0.run() },
    interpolate: { request in
      switch request {
      case let .cooling(cooling):
        return .cooling(try await cooling.run())
      case let .heating(heating):
        return .heating(try await heating.run())
      }
    },
    requiredKW: { try await $0.run() },
    sizingLimits: { systemType, houseLoad in
      try await systemType.sizingLimits(load: houseLoad)
    }
  )
}
