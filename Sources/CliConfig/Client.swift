import Dependencies
import Foundation
import Models
import XCTestDynamicOverlay

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

// TODO: Remove Template methods to their own module.
/// Represents the interactions with the ``CliConfig`` for configuring the command line tool.
///
///
public struct CliConfigClient {

  /// Return the current configuration being used.
  public var config: () async throws -> CliConfig

  /// Generate the default configuration and write it at the url.
  public var generateConfig: (URL?) async throws -> Void
  
  /// Save / update the command line configuration.
  public var save: (CliConfig) async throws -> Void
  
  /// Generate a new ``CliConfigClient``.
  ///
  /// This is usually not interacted with directly, instead use the dependency values.
  /// ```swift
  /// @Dependency(\.cliConfigClient) var configClient
  /// ```
  ///
  /// - Parameters:
  ///   - config: Return the current configuration.
  ///   - generateConfig: Generate the default configuration and write it to disk.
  ///   - save: Save the config to disk.
  public init(
    config: @escaping () async throws -> CliConfig,
    generateConfig: @escaping (URL?) async throws -> Void,
    save: @escaping (CliConfig) async throws -> Void
  ) {
    self.config = config
    self.generateConfig = generateConfig
    self.save = save
  }

  /// Generate the default configuration in the given parent directory, if applicable.
  ///
  /// If a parent directory is not provided, then it will default to the ``CliConfig/CliConfig/configDirectory``.
  ///
  /// - Parameters:
  ///   - parentDirectory: A custom directory to write the configuration to.
  public func generateConfig(
    at parentDirectory: URL? = nil
  ) async throws {
    try await generateConfig(parentDirectory)
  }

}

extension CliConfigClient: TestDependencyKey {

  public static var noop: CliConfigClient {
    .init(
      config: { .init() },
      generateConfig: { _ in try await Task.never() },
      save: { _ in try await Task.never() }
    )
  }

  public static let testValue: CliConfigClient = .init(
    config: unimplemented("\(Self.self).config"),
    generateConfig: unimplemented("\(Self.self).generateConfig"),
    save: unimplemented("\(Self.self).save")
  )
}

extension DependencyValues {
  public var cliConfigClient: CliConfigClient {
    get { self[CliConfigClient.self] }
    set { self[CliConfigClient.self] = newValue }
  }
}
