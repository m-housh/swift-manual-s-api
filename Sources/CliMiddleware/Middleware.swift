import Dependencies
import Foundation
import Models
import UserDefaultsClient
import XCTestDynamicOverlay

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Represents commands for the ``equipment-selection`` command line tool.
///
///  The 
public struct CliMiddleware {

  /// Runs configuration commands.
  public var config: @Sendable (ConfigContext) async throws -> Void
  
  /// Runs interpolation commands.
  public var interpolate: @Sendable (InterpolationContext) async throws -> Void
  
  /// Runs template commands.
  public var templates: @Sendable (TemplateContext) async throws -> Void
  
  /// Runs validation commands.
  public var validate: @Sendable (ValidationContext) async throws -> Void

  /// Create a new ``CliMiddleware`` instance.
  ///
  /// This is generally not interacted with directly, instead access the value through a dependency.
  /// ```swift
  /// @Dependency(\.cliMiddleware) var cliMiddleware
  /// ```
  ///
  /// - Parameters:
  ///   - config: Runs configuration commands.
  ///   - interpolate: Runs interpolation commands
  ///   - templates: Runs template commands.
  ///   - validate: Runs validation commands.
  public init(
    config: @escaping @Sendable (ConfigContext) async throws -> Void,
    interpolate: @escaping @Sendable (InterpolationContext) async throws -> Void,
    templates: @escaping @Sendable (TemplateContext) async throws -> Void,
    validate: @escaping @Sendable (ValidationContext) async throws -> Void
  ) {
    self.config = config
    self.interpolate = interpolate
    self.templates = templates
    self.validate = validate
  }

  /// Represents the configuration commands that can be ran.
  ///
  public enum ConfigContext: Sendable {
    
    /// Generate a local configuration.
    case generate
    
    /// Set a configuration value.
    case set(String, for: Key)
    
    /// Show the current configuration.
    case show
    
    /// Unset a configuration value.
    case unset(Key)

    /// Represents keys that can be set / unset.
    public enum Key: String, CaseIterable, Sendable {
      case anvilApiKey
      case apiBaseUrl
      case configDirectory
      case templatesDirectory
    }
  }
  
  public struct InterpolationContext: Sendable {
    
    /// The interpolation type key.
    public var key: Models.Template.PathKey
    
    /// Whether to generate a pdf from the results.
    public var generatePdf: Bool
    
    /// The input file path to use for the interpolation, if not supplied then we will
    /// look for a file that matches the name set for the key in the configuration's
    /// template paths.
    public var inputFile: URL?
    
    /// The output path for writing json or pdf results.
    public var outputPath: URL?
    
    /// Whether to write the results as a json file to the output path.
    public var writeJson: Bool
    
    /// Create a new ``CliMiddleware/InterpolationContext`` instance.
    ///
    /// - Parameters:
    ///   - key: The interpolation type key.
    ///   - generatePdf: Whether to generate a pdf from the results.
    ///   - inputFile: The input file for the interpolation.
    ///   - outputPath: The directory to write results to.
    ///   - writeJson: Whether to write the results as json to a file.
    public init(
      key: Models.Template.PathKey,
      generatePdf: Bool,
      inputFile: URL?,
      outputPath: URL?,
      writeJson: Bool
    ) {
      self.key = key
      self.generatePdf = generatePdf
      self.inputFile = inputFile
      self.outputPath = outputPath
      self.writeJson = writeJson
    }
  }

  /// Represents template commands that can be run.
  public enum TemplateContext: Sendable {
    
    /// Generate local template files for configuration overrides.
    case generate
    
    /// Remove the local templates directory.
    case remove(force: Bool)
    
    /// Generate a template from the local template overrides or the default value, if not found.
    case template(Template)

    /// Convenience for a template context.
    public static func template(
      key: Models.Template.PathKey,
      embedIn: Template.EmbedInContext? = nil,
      outputContext: Template.OutputContext
    ) -> Self {
      .template(.init(key: key, embedIn: embedIn, outputContext: outputContext))
    }

    /// Represents the context for generating template values.
    ///
    public struct Template: Sendable {
      
      /// The key for the template.
      public var key: Models.Template.PathKey
      
      /// How to embed the template if applicable.
      public var embedIn: EmbedInContext?
      
      /// How to output the template.
      public var outputContext: OutputContext

      /// Create a new ``CliMiddleware/TemplateContext/Template`` context.
      ///
      /// - Parameters:
      ///   - key: The template key.
      ///   - embedIn: Embed the template in a parent context.
      ///   - outputContext: How to output the template.
      public init(
        key: Models.Template.PathKey,
        embedIn: EmbedInContext? = nil,
        outputContext: OutputContext
      ) {
        self.key = key
        self.embedIn = embedIn
        self.outputContext = outputContext
      }

      /// Represents ways that a template can be embedded in a parent context.
      public enum EmbedInContext: Sendable {
        /// Embed the template in an interpolation.
        case interpolation
        /// Embed the template in an interpolation route.
        case route
      }

      /// Represents way to present / output the template.
      public enum OutputContext: Equatable, Sendable {
        /// Echo the template to the console.
        case echo
        /// Copy the template to the clipboard (only available on macOS).
        case copy
        /// Write the template to file.
        case write(to: URL)
      }
    }
  }

  /// Represents the context for validating files.
  ///
  public struct ValidationContext: Sendable {

    /// The template type to validate.
    public var key: Template.PathKey
    
    /// The input file to validate as the `key` type, if not provided then we will search for a file
    /// that matches the key in the configuration for template paths.
    public var inputFile: URL?

    /// Create a new ``CliMiddleware/ValidationContext``.
    ///
    /// - Parameters:
    ///   - key: The template type to validate.
    ///   - inputFile: The location of the input file for the given key.
    public init(
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
      interpolate: unimplemented("\(Self.self).interpolate"),
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
