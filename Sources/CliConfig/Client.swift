import Dependencies
import Foundation
import Models
import XCTestDynamicOverlay

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct CliConfigClient {
  public var config: () async throws -> CliConfig
  public var generateConfig: () async throws -> Void
  public var generateTemplates: (URL?) async throws -> Void
  public var save: (CliConfig) async throws -> Void
  public var template: (KeyPath<CliConfig.TemplatePaths, String>) async throws -> Data
  
  public init(
    config: @escaping () async throws -> CliConfig,
    generateConfig: @escaping () async throws -> Void,
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
  
  public func generateTemplates(
    at parentDirectory: URL?
  ) async throws {
    try await generateTemplates(parentDirectory)
  }
  
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
      generateConfig: { },
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
