import Dependencies
import Foundation
import Logging

extension DependencyValues {
  public var logger: Logger {
    get { self[LoggingKey.self] }
    set { self[LoggingKey.self] = newValue }
  }
}

private enum LoggingKey: DependencyKey {
  static let testValue = Logger(label: ProcessInfo.processInfo.processName)
  static let liveValue = Logger(label: ProcessInfo.processInfo.processName)
}
