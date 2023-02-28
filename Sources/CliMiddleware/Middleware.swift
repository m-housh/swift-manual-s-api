import Dependencies
import Foundation
import Models
import UserDefaultsClient
import XCTestDynamicOverlay

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct CliMiddleware {
  
  public var config: (ConfigContext) async throws -> Void
  public var templates: (TemplateContext) async throws -> Void
  public var validate: (ValidationContext) async throws -> Void
  
  public init(
    config: @escaping (ConfigContext) async throws -> Void,
    templates: @escaping (TemplateContext) async throws -> Void,
    validate: @escaping (ValidationContext) async throws -> Void
  ) {
    self.config = config
    self.templates = templates
    self.validate = validate
  }
  
  public enum ConfigContext: Sendable {
    case generate
    case set(String, for: SetKey)
    case show
    case unset(UnSetKey)
    
    public enum SetKey: String, CaseIterable, Sendable {
      case anvilApiKey
      case apiBaseUrl
      case configDirectory
      case templatesDirectory
    }
    
    public enum UnSetKey: String, CaseIterable, Sendable {
      case anvilApiKey
      case apiBaseUrl
      case configDirectory
      case templatesDirectory
    }

  }
  
  public enum TemplateContext: Sendable {
    case generate
    case remove(force: Bool)
    case template(Template)
    
    public static func template(
      key: Models.Template.PathKey,
      embedIn: Template.EmbedInContext? = nil,
      outputContext: Template.OutputContext
    ) -> Self {
      .template(.init(key: key, embedIn: embedIn, outputContext: outputContext))
    }
    
    public struct Template: Sendable {
      public var key: Models.Template.PathKey
      public var embedIn: EmbedInContext?
      public var outputContext: OutputContext
      
      public init(
        key: Models.Template.PathKey,
        embedIn: EmbedInContext? = nil,
        outputContext: OutputContext
      ) {
        self.key = key
        self.embedIn = embedIn
        self.outputContext = outputContext
      }
      
      public enum EmbedInContext: Sendable {
        case interpolation
        case route
      }
      
      public enum OutputContext: Equatable, Sendable {
        case echo
        case copy
        case write(to: URL)
      }
    }
  }
  
  public struct ValidationContext: Sendable {
   
    public var key: Template.PathKey
    public var inputFile: URL?
    
    public  init(
      key: Template.PathKey,
      inputFile: URL? = nil
    ) {
      self.key = key
      self.inputFile = inputFile
    }
  }
}

extension CliMiddleware: TestDependencyKey {
  
  public static var testValue: CliMiddleware {
    .init(
      config: unimplemented("\(Self.self).config"),
      templates: unimplemented("\(Self.self).templates"),
      validate: unimplemented("\(Self.self).validate")
    )
  }
}

extension DependencyValues {
  public var cliMiddleware: CliMiddleware {
    get { self[CliMiddleware.self] }
    set { self[CliMiddleware.self] = newValue }
  }
}
