@_exported import CliConfig
import ConcurrencyHelpers
import Dependencies
import Foundation

extension CliConfigClient: DependencyKey {
  
  public static var liveValue: CliConfigClient {
    actor Session {
      nonisolated let config: Isolated<CliConfig> = .init(wrappedValue: CliConfigLive.config())
      
      // fix.
      func generateTemplates(at path: URL?) async throws {
       // do something
      }
      
      func generateConfig() async throws {
        try await self.writeConfig()
      }
      
      private func writeConfig() async throws {
        
        let configDirectory = config.value.configPath.deletingLastPathComponent()
        
        try? FileManager.default.createDirectory(
          at: configDirectory,
          withIntermediateDirectories: true
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        let data = try encoder.encode(self.config.value)
        try data.write(to: config.value.configPath)
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
        return try Data(contentsOf: templateFilePath)
      }
    }
    
    let session = Session()
    
    return .init(
      config: {
        session.config.value
      },
      generateConfig: session.generateConfig,
      generateTemplates: session.generateTemplates(at:),
      save: session.save(config:),
      template: session.template(for:)
    )
  }
}

fileprivate func config() -> CliConfig {
  let defaultConfig = CliConfig()
  let decoder = JSONDecoder()
  let encoder = JSONEncoder()
  
  let defaultConfigDict = (try? encoder.encode(defaultConfig))
    .flatMap { try? decoder.decode([String: String].self, from: $0) }
  ?? [:]
  
  let localConfigDict = (try? Data(contentsOf: defaultConfig.configPath))
    .flatMap { try? decoder.decode([String: String].self, from: $0) }
  ?? [:]
  
  let configEnvironment = (try? encoder.encode(ProcessInfo.processInfo.environment))
    .flatMap { try? decoder.decode(ConfigEnvironment.self, from: $0) }
  
  let configDict = defaultConfigDict
    .merging(localConfigDict, uniquingKeysWith: { $1 })
  
  var config = (try? JSONSerialization.data(withJSONObject: configDict))
    .flatMap { try? decoder.decode(CliConfig.self, from: $0) }
  ?? defaultConfig
 
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
