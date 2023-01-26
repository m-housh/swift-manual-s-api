import ManualSClient
import UtilsClient

extension ManualSClient {
  
  public static func live(utils: UtilsClient) -> Self {
    Self.init(
      interpolate: { request in
        switch request {
        case let .cooling(cooling):
          return .cooling(try await cooling.run())
        case let .heating(heating):
          return .heating(try await heating.run(utils: utils))
        }
      }
    )
  }
}
