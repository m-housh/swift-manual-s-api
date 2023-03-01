import ClientConfig
import ConcurrencyHelpers
import Dependencies
import FileClient
import Foundation
import Logging
import LoggingDependency
import Models
@_exported import TemplateClient
import UserDefaultsClient

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension TemplateClient: DependencyKey {

  public static func live(
    jsonEncoder: JSONEncoder = .init(),
    templateDirectory defaultTemplateDirectory: URL = .defaultTemplateDirectory
  ) -> Self {
    @Dependency(\.userDefaults) var userDefaults

    actor Session {
      @Dependency(\.logger) var logger
      @Dependency(\.configClient) var configClient
      @Dependency(\.fileClient) var fileClient

      private let jsonEncoder: JSONEncoder
      nonisolated let templateDirectory: Isolated<URL>

      init(
        jsonEncoder: JSONEncoder,
        templateDirectory: URL,
        userDefaults: UserDefaultsClient
      ) {
        self.jsonEncoder = jsonEncoder
        self.templateDirectory = .init(
          templateDirectory,
          didSet: { _, newValue in
            userDefaults.setUrl(newValue, forKey: .templateDirectory)
          }
        )
      }

      func generateTemplates() async throws {
        let config = await configClient.config()
        try await fileClient.createDirectory(at: templateDirectory.value)
        logger.debug("Generating templates at: \(templateDirectory.value.absoluteURL)")
        for key in Template.PathKey.allCases {
          let templatePath = config.templatePaths[keyPath: key.templateKeyPath]
          let templateUrl = templateDirectory.value.appendingPathComponent(templatePath)
          let data = try jsonEncoder.encode(key.mock)
          try await fileClient.write(
            data: data,
            to: templateUrl
          )
          logger.debug("Wrote template at: \(templateUrl.absoluteString)")
        }
      }

      func removeTemplates() throws {
        try FileManager.default.removeItem(at: templateDirectory.value)
      }

      func routeTemplate(
        for key: Template.EmbeddableKey
      ) async throws -> ServerRoute.Api.Route.Interpolation.Route {
        let config = await configClient.config()
        let keyPath = key.templateKeyPath

        let routeData = try await templateData(
          jsonEncoder: jsonEncoder,
          keyPath: keyPath,
          logger: logger,
          fileClient: fileClient,
          paths: config.templatePaths,
          templateDirectory: templateDirectory.value
        )
        let pathKey = Template.PathKey(keyPath: keyPath, paths: config.templatePaths)!
        guard let embeddableKey = pathKey.embeddableKey else {
          // this should really never happen.
          struct NotEmbeddableError: Error {}
          throw NotEmbeddableError()
        }
        return try embeddableKey.embedInRoute(routeData)
      }

      func setTemplateDirectory(to url: URL) {
        self.templateDirectory.value = url
      }

      func template(
        for keyPath: KeyPath<Template.Path, String>,
        inInterpolation: Bool
      ) async throws -> Data {

        let config = await configClient.config()

        let routeData = try await templateData(
          jsonEncoder: jsonEncoder,
          keyPath: keyPath,
          logger: logger,
          fileClient: fileClient,
          paths: config.templatePaths,
          templateDirectory: templateDirectory.value
        )

        // Early out if we don't need to embed the template in an interpolation.
        if inInterpolation == false {
          return routeData
        }

        // Embed in a base interpolation.
        let key = Template.PathKey(keyPath: keyPath, paths: config.templatePaths)!

        let baseInterpolation = await readBaseInterpolation(
          basePath: templateDirectory.value,
          logger: logger,
          fileClient: fileClient,
          paths: config.templatePaths
        )

        guard let embeddableKey = key.embeddableKey else {
          struct NotEmbeddableKeyError: Error {}
          throw NotEmbeddableKeyError()
        }

        return try jsonEncoder.encode(
          embeddableKey.embed(data: routeData, in: baseInterpolation)
        )
      }
    }

    let templateDirectory =
      userDefaults.url(forKey: .templateDirectory)
      ?? defaultTemplateDirectory

    let session = Session(
      jsonEncoder: jsonEncoder,
      templateDirectory: templateDirectory,
      userDefaults: userDefaults
    )

    return .init(
      generateTemplates: session.generateTemplates,
      removeTemplateDirectory: { try await session.removeTemplates() },
      routeTemplate: session.routeTemplate(for:),
      setTemplateDirectory: { await session.setTemplateDirectory(to: $0) },
      template: session.template(for:inInterpolation:),
      templateDirectory: { session.templateDirectory.value }
    )
  }

  public static let liveValue: TemplateClient = .live()

  /// Load a template for the given path key.
  ///
  /// - Parameters:
  ///   - pathKey: The path key to load the template for.
  public func template(for pathKey: Template.PathKey, inInterpolation: Bool = false) async throws
    -> Data
  {
    try await self.template(
      for: pathKey.templateKeyPath,
      inInterpolation: inInterpolation
    )
  }
}

extension FileClient {

  fileprivate func readBaseInterpolation(from url: URL) async throws -> Template.BaseInterpolation {
    let data = try await self.read(from: url)
    return try JSONDecoder().decode(Template.BaseInterpolation.self, from: data)
  }
}

private func readBaseInterpolation(
  basePath: URL,
  logger: Logger,
  fileClient: FileClient,
  paths: Template.Path
) async -> Template.BaseInterpolation {
  do {
    let baseInterpolationPath = paths[keyPath: \.baseInterpolation]
    let baseInterpolationUrl = basePath.appendingPathComponent(baseInterpolationPath)
    let baseInterpolation = try await fileClient.readBaseInterpolation(from: baseInterpolationUrl)
    logger.debug("Loaded base interpolation from: \(baseInterpolationUrl.absoluteString)")
    return baseInterpolation
  } catch {
    logger.debug("No base interpolation found, using default.")
    return .mock
  }
}

private func templateData(
  jsonEncoder: JSONEncoder,
  keyPath: KeyPath<Template.Path, String>,
  logger: Logger,
  fileClient: FileClient,
  paths: Template.Path,
  templateDirectory: URL
) async throws -> Data {
  struct TemplateNotFoundError: Error {}
  let filePath = paths[keyPath: keyPath]
  let templateUrl = templateDirectory.appendingPathComponent(filePath)
  let routeData: Data
  do {
    // attempt to read template from disk.
    let file = try await fileClient.read(
      from: templateUrl
    )
    logger.debug("Read template from file: \(templateUrl.absoluteString)")
    routeData = file
  } catch {
    // attempt to return a mock for the given key-path
    guard let key = Template.PathKey(keyPath: keyPath, paths: paths)
    else {
      throw TemplateNotFoundError()
    }
    logger.debug(
      """
        No file found at: \(templateUrl.absoluteString)
        Returning mock data.
      """)
    routeData = try jsonEncoder.encode(key.mock)
  }

  return routeData
}
