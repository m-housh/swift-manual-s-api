import Dependencies
import Foundation
@_exported import Logging

extension DependencyValues {

  /// Access a ``Logging/Logger`` dependency.
  public var logger: Logger {
    get { self[LoggingKey.self] }
    set { self[LoggingKey.self] = newValue }
  }
}

private enum LoggingKey: DependencyKey {
  static let testValue = Logger(label: ProcessInfo.processInfo.processName)
  static let liveValue = Logger(label: ProcessInfo.processInfo.processName)
}
