import Dependencies
import Foundation
import Models
import XCTestDynamicOverlay

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Represents the interactions with the ``CliConfig`` for configuring the command line tool.
///
///
public struct CliConfigClient {

  /// Return the current configuration being used.
  public var config: () async throws -> CliConfig

  /// Generate the default configuration and write it at the url.
  public var generateConfig: (URL?) async throws -> Void

  /// Generate the default templates and write them at the url.
  public var generateTemplates: (URL?) async throws -> Void

  /// Save / update the command line configuration.
  public var save: (CliConfig) async throws -> Void

  /// Retrieve a template for the given template path.
  public var template: (KeyPath<CliConfig.TemplatePaths, String>) async throws -> Data

  public init(
    config: @escaping () async throws -> CliConfig,
    generateConfig: @escaping (URL?) async throws -> Void,
    generateTemplates: @escaping (URL?) async throws -> Void,
    save: @escaping (CliConfig) async throws -> Void,
    template: @escaping (KeyPath<CliConfig.TemplatePaths, String>) async throws -> Data
  ) {
    self.config = config
    self.generateConfig = generateConfig
    self.generateTemplates = generateTemplates
    self.save = save
    self.template = template
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

  /// Generate the default templates and write them at the url.
  ///
  /// If a parent directory is not provided, then it will default to the ``CliConfig/CliConfig/templateDirectoryPath``
  /// - Parameters:
  ///   - parentDirectory: A custom directory to write the templates to.
  ///
  public func generateTemplates(
    at parentDirectory: URL? = nil
  ) async throws {
    try await generateTemplates(parentDirectory)
  }

  /// Retrieve a template for the given template path.
  ///
  /// - Parameters:
  ///   - path: The template path to retrieve the template for.
  public func template(
    for path: KeyPath<CliConfig.TemplatePaths, String>
  ) async throws -> Data {
    try await self.template(path)
  }
}

extension CliConfigClient: TestDependencyKey {

  public static var noop: CliConfigClient {
    .init(
      config: { .init() },
      generateConfig: { _ in },
      generateTemplates: { _ in },
      save: { _ in },
      template: { _ in Data() }
    )
  }

  public static let testValue: CliConfigClient = .init(
    config: unimplemented("\(Self.self).config"),
    generateConfig: unimplemented("\(Self.self).generateConfig"),
    generateTemplates: unimplemented("\(Self.self).generateTemplates"),
    save: unimplemented("\(Self.self).save"),
    template: unimplemented("\(Self.self).template")
  )
}

extension DependencyValues {
  public var cliConfigClient: CliConfigClient {
    get { self[CliConfigClient.self] }
    set { self[CliConfigClient.self] = newValue }
  }
}
