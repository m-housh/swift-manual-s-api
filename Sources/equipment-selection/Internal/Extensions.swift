import ArgumentParser
import CliMiddleware
import LoggingDependency
import LoggingFormatAndPipe
import Models

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Logger {

  static var cliLogger: Self {
    Logger(label: "equipment-selection") { _ in
      return LoggingFormatAndPipe.Handler(
        formatter: BasicFormatter([.message]),
        pipe: LoggerTextOutputStreamPipe.standardOutput
      )
    }
  }

  static var cliLoggerWithLevel: Self {
    Logger(label: "equipment-selection") { _ in
      return LoggingFormatAndPipe.Handler(
        formatter: BasicFormatter([.level, .message]),
        pipe: LoggerTextOutputStreamPipe.standardOutput
      )
    }
  }
}

extension Template.PathKey: EnumerableFlag {}
extension CliMiddleware.ConfigContext.SetKey: EnumerableFlag { }
extension CliMiddleware.ConfigContext.UnSetKey: EnumerableFlag { }

extension Template.Path {

  func parseUrl(url: URL?, with key: Template.PathKey) -> URL {
    guard let url else {
      return URL(fileURLWithPath: self.fileName(for: key))
    }
    return url
  }
}
