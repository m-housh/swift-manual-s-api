@_exported import UtilsClient

extension UtilsClient {
  
  public static let live = Self.init(
    balancePoint: { request in
      try await request.run()
    },
    derating: { request in
      try await request.systemType.derating(elevation: request.elevation)
    },
    requiredKW: { request in
        .init(requiredKW: try await request.run())
    },
    sizingLimits: { request in
      try await request.systemType.sizingLimits(load: request.houseLoad)
    }
  )
}
