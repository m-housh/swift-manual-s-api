@_exported import CliConfig
import ConcurrencyHelpers
import Dependencies
import FileClient
import Foundation

extension CliConfigClient: DependencyKey {
  
  public static var liveValue: CliConfigClient {
  
    actor Session {
      
      @Dependency(\.fileClient) var fileClient
      
      nonisolated let config: Isolated<CliConfig> = .init(wrappedValue: CliConfigLive.config())
      
      // fix.
      func generateTemplates(at path: URL?) async throws {
       // do something
      }
      
      func generateConfig(at path: URL?) async throws {
        try await self.writeConfig(at: path)
      }
      
      private func writeConfig(at path: URL? = nil) async throws {
        
        let configDirectory = path
        ?? config.value.configPath.deletingLastPathComponent()
        
        try await fileClient.createDirectory(at: configDirectory)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        let data = try encoder.encode(config.value.localConfig)
        try await fileClient.write(data: data, to: config.value.configPath)
      }
      
      func save(config: CliConfig) async throws {
        self.config.value = config
        try await self.writeConfig()
      }
      
      func template(
        for keyPath: KeyPath<CliConfig.TemplatePaths, String>
      ) async throws -> Data {
        
        let templatesDirectory: URL
        if let directory = config.templateDirectoryPath {
          templatesDirectory = URL(fileURLWithPath: directory, isDirectory: true)
        } else {
          templatesDirectory = config.value.configPath
            .deletingLastPathComponent()
            .appendingPathComponent("templates", conformingTo: .directory)
        }
       
        let templatePath = config.templatePaths[keyPath: keyPath]
        let templateFilePath = templatesDirectory.appendingPathComponent(templatePath, conformingTo: .json)
        return try await fileClient.read(from: templateFilePath)
      }
    }
    
    let session = Session()
    
    return .init(
      config: {
        session.config.value
      },
      generateConfig: session.generateConfig(at:),
      generateTemplates: session.generateTemplates(at:),
      save: session.save(config:),
      template: session.template(for:)
    )
  }
}

fileprivate func config() -> CliConfig {
  
  var config = CliConfig()
  let decoder = JSONDecoder()
  let encoder = JSONEncoder()
 
  if let localConfig = (try? Data(contentsOf: config.configPath))
    .flatMap({ try? decoder.decode(LocalConfig.self, from: $0) })
  {
    localConfig.merge(with: &config)
  }
  
  let configEnvironment = (try? encoder.encode(ProcessInfo.processInfo.environment))
    .flatMap { try? decoder.decode(ConfigEnvironment.self, from: $0) }

  if let configEnvironment {
    configEnvironment.merge(with: &config)
  }
  
  return config
}

fileprivate struct ConfigEnvironment: Decodable {
  public var anvilApiKey: String?
  public var apiBaseUrl: String?
  public var configDirectory: String?
  public var templateDirectoryPath: String?
  
  func merge(with config: inout CliConfig) {
    if let anvilApiKey { config.anvilApiKey = anvilApiKey }
    if let apiBaseUrl { config.apiBaseUrl = apiBaseUrl }
    if let configDirectory { config.configDirectory = configDirectory }
    if let templateDirectoryPath { config.templateDirectoryPath = templateDirectoryPath }
  }
  
  enum CodingKeys: String, CodingKey {
    case anvilApiKey = "ANVIL_API_KEY"
    case apiBaseUrl = "API_BASE_URL"
    case configDirectory = "EQUIPMENT_SELCTION_CONFIG_DIR"
    case templateDirectoryPath = "EQUIPMENT_SELECTION_TEMPLATES"
  }
}

// Represents the config values that can be read / saved to disk.
fileprivate struct LocalConfig: Codable {
  var anvilApiKey: String?
  var apiBaseUrl: String?
  var templateDirectoryPath: String?
  var templateIds: CliConfig.TemplateIds?
  var templatePaths: CliConfig.TemplatePaths?
  
  init(cliConfig: CliConfig) {
    self.anvilApiKey = cliConfig.anvilApiKey
    self.apiBaseUrl = cliConfig.apiBaseUrl
    self.templateDirectoryPath = cliConfig.templateDirectoryPath
    self.templateIds = cliConfig.templateIds
    self.templatePaths = cliConfig.templatePaths
  }
  
  func merge(with config: inout CliConfig) {
    if let anvilApiKey { config.anvilApiKey = anvilApiKey }
    if let apiBaseUrl { config.apiBaseUrl = apiBaseUrl }
    if let templateDirectoryPath { config.templateDirectoryPath = templateDirectoryPath }
    if let templateIds { config.templateIds = templateIds }
    if let templatePaths { config.templatePaths = templatePaths}
  }
}

fileprivate extension CliConfig {
  var localConfig: LocalConfig { .init(cliConfig: self) }
}
