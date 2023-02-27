import Dependencies
import Foundation
import Models
import XCTestDynamicOverlay

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

// TODO: Allow setting user-defaults values for anvil-api-key, config-directory, template-directory, etc.
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

  public var setApiBaseUrl: (String?) async -> Void
  public var setAnvilApiKey: (String?) async -> Void
  public var setConfigDirectory: (String) async -> Void
  public var setTemplateDirectoryPath: (String?) async -> Void

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
    save: @escaping (CliConfig) async throws -> Void,
    setApiBaseUrl: @escaping (String?) async -> Void,
    setAnvilApiKey: @escaping (String?) async -> Void,
    setConfigDirectory: @escaping (String) async -> Void,
    setTemplateDirectoryPath: @escaping (String?) async -> Void
  ) {
    self.config = config
    self.generateConfig = generateConfig
    self.save = save
    self.setApiBaseUrl = setApiBaseUrl
    self.setAnvilApiKey = setAnvilApiKey
    self.setConfigDirectory = setConfigDirectory
    self.setTemplateDirectoryPath = setTemplateDirectoryPath
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
      save: { _ in try await Task.never() },
      setApiBaseUrl: { _ in },
      setAnvilApiKey: { _ in },
      setConfigDirectory: { _ in },
      setTemplateDirectoryPath: { _ in }
    )
  }

  public static let testValue: CliConfigClient = .init(
    config: unimplemented("\(Self.self).config"),
    generateConfig: unimplemented("\(Self.self).generateConfig"),
    save: unimplemented("\(Self.self).save"),
    setApiBaseUrl: unimplemented("\(Self.self).setApiBaseUrl"),
    setAnvilApiKey: unimplemented("\(Self.self).setAnvilApiKey"),
    setConfigDirectory: unimplemented("\(Self.self).setConfigDirectory"),
    setTemplateDirectoryPath: unimplemented("\(Self.self).setTemplateDirectoryPath")
  )
}

extension DependencyValues {
  public var cliConfigClient: CliConfigClient {
    get { self[CliConfigClient.self] }
    set { self[CliConfigClient.self] = newValue }
  }
}
