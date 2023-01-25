import ManualSClient

extension ManualSClient {
  
  public static let live = Self.init(
    derating: { try await $0.run() },
    heatingInterpolation: { try await $0.run() },
    interpolate: Self.noop.interpolate, // fix
    requiredKW: { try await $0.run() },
    sizingLimits: { systemType, houseLoad in
      try await systemType.sizingLimits(load: houseLoad)
    }
  )
}
