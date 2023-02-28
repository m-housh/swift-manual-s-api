import Dependencies
import Foundation

extension JSONEncoder: DependencyKey {
  public static func cliEncoder(
    _ formatting: JSONEncoder.OutputFormatting
  ) -> JSONEncoder {
    let encoder = JSONEncoder()
    encoder.outputFormatting = formatting
    return encoder
  }

  public static var cliEncoder: JSONEncoder {
    self.cliEncoder([.prettyPrinted, .sortedKeys])
  }

  public static let liveValue: JSONEncoder = .cliEncoder
}

extension JSONDecoder: DependencyKey {
  public static let liveValue: JSONDecoder = .init()
}

public struct JSONCoders: DependencyKey {
  public var jsonDecoder: JSONDecoder
  public var jsonEncoder: JSONEncoder

  public init(
    jsonDecoder: JSONDecoder = .liveValue,
    jsonEncoder: JSONEncoder = .liveValue
  ) {
    self.jsonDecoder = jsonDecoder
    self.jsonEncoder = jsonEncoder
  }

  public static let liveValue: JSONCoders = .init()
}

extension DependencyValues {
  public var jsonCoders: JSONCoders {
    get { self[JSONCoders.self] }
    set { self[JSONCoders.self] = newValue }
  }
}
