import ConcurrencyHelpers
import Dependencies
import Foundation
import Models
import XCTestDynamicOverlay

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Represents interactions with templates to be used in interpolations.
///
///
public struct TemplateClient {

  /// Generate templates for custom configuration.
  public var generateTemplates: () async throws -> Void

  /// Remove the templates directory.
  public var removeTemplateDirectory: () async throws -> Void

  /// Return a template embedded in an interpolation route.
  public var routeTemplate:
    (KeyPath<Template.Path, String>) async throws -> ServerRoute.Api.Route.Interpolation.Route

  /// Update the template directory where we search for templates.
  public var setTemplateDirectory: (URL) async -> Void

  /// Load a template for the given key.
  public var template: (KeyPath<Template.Path, String>, Bool) async throws -> Data

  /// Return the current template directory.
  public var templateDirectory: () -> URL

  /// Create a new ``TemplateClient``.
  ///
  /// This is normally not interacted with directly, instead access the template client as a dependency.
  ///
  /// ```swift
  /// @Dependency(\.templateClient) var templateClient
  /// ```
  ///
  /// - Parameters:
  ///   - generateTemplates: Generate templates for customization.
  ///   - removeTemplateDirectory: Remove the templates directory.
  ///   - routeTemplate: Return a template embedded in an interpolation route.
  ///   - setTemplateDirectory: Set the template directory.
  ///   - template: Load a template for the given key.
  ///   - templateDirectory: Return the current template directory.
  public init(
    generateTemplates: @escaping () async throws -> Void,
    removeTemplateDirectory: @escaping () async throws -> Void,
    routeTemplate: @escaping (KeyPath<Template.Path, String>) async throws -> ServerRoute.Api.Route
      .Interpolation.Route,
    setTemplateDirectory: @escaping (URL) async -> Void,
    template: @escaping (KeyPath<Template.Path, String>, Bool) async throws -> Data,
    templateDirectory: @escaping () -> URL
  ) {
    self.generateTemplates = generateTemplates
    self.removeTemplateDirectory = removeTemplateDirectory
    self.routeTemplate = routeTemplate
    self.setTemplateDirectory = setTemplateDirectory
    self.template = template
    self.templateDirectory = templateDirectory
  }

  public func template(
    for path: KeyPath<Template.Path, String>,
    inInterpolation: Bool = false
  ) async throws -> Data {
    try await self.template(path, inInterpolation)
  }

  public func routeTemplate(
    for keyPath: KeyPath<Template.Path, String>
  ) async throws -> ServerRoute.Api.Route.Interpolation.Route {
    try await self.routeTemplate(keyPath)
  }
}

extension TemplateClient: TestDependencyKey {
  public static let noop = Self.init(
    generateTemplates: { try await Task.never() },
    removeTemplateDirectory: { try await Task.never() },
    routeTemplate: { _ in try await Task.never() },
    setTemplateDirectory: { _ in },
    template: { _, _ in try await Task.never() },
    templateDirectory: { .defaultTemplateDirectory }
  )

  public static var testValue: TemplateClient = .init(
    generateTemplates: unimplemented("\(Self.self).generateTemplate"),
    removeTemplateDirectory: unimplemented("\(Self.self).removeTemplateDirectory"),
    routeTemplate: unimplemented("\(Self.self).routeTemplate"),
    setTemplateDirectory: unimplemented("\(Self.self)"),
    template: unimplemented("\(Self.self).template", placeholder: Data()),
    templateDirectory: unimplemented(
      "\(Self.self).templateDirectory", placeholder: URL.defaultTemplateDirectory)
  )
}

extension URL {
  public static var defaultTemplateDirectory: URL {
    let baseUrl: URL

    if let xdg_home = ProcessInfo.processInfo.environment["XDG_CONFIG_HOME"] {
      baseUrl = URL(fileURLWithPath: xdg_home)
    } else {
      baseUrl = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".config")
    }

    return
      baseUrl
      .appendingPathComponent("equipment-selection")
      .appendingPathComponent("templates")
  }
}

extension DependencyValues {
  public var templateClient: TemplateClient {
    get { self[TemplateClient.self] }
    set { self[TemplateClient.self] = newValue }
  }
}
