import Dependencies
import Foundation
import Logging
import LoggingDependency
import XCTestDynamicOverlay

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Represents interactions with the file system and constructing common URL's needed throughout the application.
///
public struct FileClient {

  /// Retrieve the configuration directory.
  public var configDirectory: () -> URL

  /// Create a directory at the given url.
  public var createDirectory: (URL) async throws -> Void

  /// Retrieve the home directory, either the current user's home directory or application home directory depending on the platform.
  public var homeDirectory: () -> URL

  /// Read the contents from the given url.
  public var read: (URL) async throws -> Data

  /// Write the data to the given url.
  public var write: (Data, URL) async throws -> Void

  /// Create a new ``FileClient`` instance.
  ///
  /// This is generally not interacted with directly, instead use the dependency value.
  /// ```swift
  /// @Dependency(\.fileClient) var fileClient
  /// ```
  ///
  /// - Parameters:
  ///   - configDirectory: The configuration directory.
  ///   - createDirectory: Create a  directory at the given url.
  ///   - homeDirectory: The home directory url.
  ///   - read: Read the contents of a file at the given url.
  ///   - write: Write the data to the given url.
  public init(
    configDirectory: @escaping () -> URL,
    createDirectory: @escaping (URL) async throws -> Void,
    homeDirectory: @escaping () -> URL,
    read: @escaping (URL) async throws -> Data,
    write: @escaping (Data, URL) async throws -> Void
  ) {
    self.configDirectory = configDirectory
    self.createDirectory = createDirectory
    self.homeDirectory = homeDirectory
    self.read = read
    self.write = write
  }

  /// Create a directory at the given url.
  ///
  /// - Parameters:
  ///   - url: The url to create the directory at.
  public func createDirectory(at url: URL) async throws {
    try await self.createDirectory(url)
  }

  /// Create a directory at the given url.
  ///
  /// - Parameters:
  ///   - path: The path to create the directory at.
  public func createDirectory(at path: String) async throws {
    try await self.createDirectory(path.fileUrl())
  }

  /// Read the contents of a file from the given url.
  ///
  /// - Parameters:
  ///   - url: The file url to read the contents from.
  public func read(from url: URL) async throws -> Data {
    try await self.read(url)
  }

  /// Read the contents of a file from the given path.
  ///
  /// - Parameters:
  ///   - path: The file path to read the contents from.
  public func read(
    from path: String
  ) async throws -> Data {
    try await self.read(path.fileUrl())
  }

  /// Write the data to a file at the given url.
  ///
  /// - Parameters:
  ///   - url: The file url to write the data to.
  public func write(
    data: Data,
    to url: URL
  ) async throws {
    try await self.write(data, url)
  }

  /// Write the data to a file at the given path.
  ///
  /// - Parameters:
  ///   - path: The file path to write the data to.
  public func write(
    data: Data,
    to path: String
  ) async throws {
    try await self.write(data, path.fileUrl())
  }

  public static let XDG_CONFIG_HOME_KEY = "XDG_CONFIG_HOME"
}

extension FileClient: DependencyKey {

  /// A ``FileClient/FileClient`` that does not perform any actions.
  public static let noop = Self.init(
    configDirectory: { URL(fileURLWithPath: "noop") },
    createDirectory: { _ in },
    homeDirectory: { URL(fileURLWithPath: "noop") },
    read: { _ in Data() },
    write: { _, _ in }
  )

  public static func mock(readData: Data) -> Self {
    .init(
      configDirectory: { .configDirectory },
      createDirectory: { _ in },
      homeDirectory: { .homeDirectory },
      read: { _ in readData },
      write: { _, _ in }
    )
  }

  /// An unimplemented ``FileClient``.
  public static let testValue: FileClient = .init(
    configDirectory: unimplemented(
      "\(Self.self).configDirectory", placeholder: URL(fileURLWithPath: "unimplemented")),
    createDirectory: unimplemented("\(Self.self).createDirectory"),
    homeDirectory: unimplemented(
      "\(Self.self).homeDirectory", placeholder: URL(fileURLWithPath: "unimplemented")),
    read: unimplemented("\(Self.self).read", placeholder: Data()),
    write: unimplemented("\(Self.self).write")
  )

  /// The live implementation for a ``FileClient``.
  public static var liveValue: FileClient {

    @Dependency(\.logger) var logger

    return .init(
      configDirectory: {
        .configDirectory
      },
      createDirectory: { url in
        logger.debug("Creating directory at: \(url.absoluteString)")
        try FileManager.default
          .createDirectory(at: url, withIntermediateDirectories: true)
      },
      homeDirectory: {
        .homeDirectory
      },
      read: { url in
        logger.debug("Reading contents of: \(url.absoluteString)")
        return try Data(contentsOf: url)
      },
      write: { data, url in
        logger.debug("Writing data to: \(url.absoluteString)")
        try data.write(to: url, options: .atomic)
      }
    )
  }
}

extension URL {
  fileprivate static var homeDirectory: Self {
    URL(fileURLWithPath: NSHomeDirectory())
  }

  fileprivate static var configDirectory: Self {
    guard let xdgHome = ProcessInfo.processInfo.environment[FileClient.XDG_CONFIG_HOME_KEY] else {
      return homeDirectory.appendingPathComponent(".config")
    }
    return xdgHome.fileUrl()
  }
}

extension DependencyValues {

  /// Access a ``FileClient`` as a dependency.
  public var fileClient: FileClient {
    get { self[FileClient.self] }
    set { self[FileClient.self] = newValue }
  }
}

extension String {
  public func fileUrl() -> URL {
    URL(fileURLWithPath: self)
  }
}
