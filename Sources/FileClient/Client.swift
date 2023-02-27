import Dependencies
import Foundation
import Logging
import LoggingDependency
import XCTestDynamicOverlay

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Represents interactions with the file system.
///
public struct FileClient {

  /// Create a directory at the given url.
  public var createDirectory: (URL) async throws -> Void

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
  ///   - createDirectory: Create a  directory at the given url.
  ///   - read: Read the contents of a file at the given url.
  ///   - write: Write the data to the given url.
  public init(
    createDirectory: @escaping (URL) async throws -> Void,
    read: @escaping (URL) async throws -> Data,
    write: @escaping (Data, URL) async throws -> Void
  ) {
    self.createDirectory = createDirectory
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
    try await self.createDirectory(URL(fileURLWithPath: path))
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
    let url = URL(fileURLWithPath: path)
    return try await self.read(url)
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
    let url = URL(fileURLWithPath: path)
    try await self.write(data, url)
  }
}

extension FileClient: DependencyKey {

  /// A ``FileClient/FileClient`` that does not perform any actions.
  public static let noop = Self.init(
    createDirectory: { _ in },
    read: { _ in Data() },
    write: { _, _ in }
  )

  /// An unimplemented ``FileClient``.
  public static let testValue: FileClient = .init(
    createDirectory: unimplemented("\(Self.self).createDirectory"),
    read: unimplemented("\(Self.self).read"),
    write: unimplemented("\(Self.self).write")
  )

  /// The live implementation for a ``FileClient``.
  public static var liveValue: FileClient {

    @Dependency(\.logger) var logger

    return .init(
      createDirectory: { url in
        logger.debug("Creating directory at: \(url.absoluteString)")
        try FileManager.default
          .createDirectory(at: url, withIntermediateDirectories: true)
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

extension DependencyValues {

  /// Access a ``FileClient`` as a dependency.
  public var fileClient: FileClient {
    get { self[FileClient.self] }
    set { self[FileClient.self] = newValue }
  }
}
