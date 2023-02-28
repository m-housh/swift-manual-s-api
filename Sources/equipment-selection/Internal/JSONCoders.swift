import Dependencies
import Foundation

extension JSONEncoder: DependencyKey {
  static func cliEncoder(
    _ formatting: JSONEncoder.OutputFormatting
  ) -> JSONEncoder {
    let encoder = JSONEncoder()
    encoder.outputFormatting = formatting
    return encoder
  }

  static var cliEncoder: JSONEncoder {
    self.cliEncoder([.prettyPrinted, .sortedKeys])
  }

  public static let liveValue: JSONEncoder = .cliEncoder
}

extension JSONDecoder: DependencyKey {
  public static let liveValue: JSONDecoder = .init()
}

struct JSONCoders: DependencyKey {
  var jsonDecoder: JSONDecoder = .liveValue
  var jsonEncoder: JSONEncoder = .liveValue

  static var liveValue: JSONCoders = .init()
}
extension DependencyValues {
  var jsonCoders: JSONCoders {
    get { self[JSONCoders.self] }
    set { self[JSONCoders.self] = newValue }
  }
}
