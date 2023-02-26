import Foundation
import Models
import Tagged

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct CliConfig: Codable, Equatable, Sendable {
  public var anvilApiKey: String
  public var apiBaseUrl: String?
  public var configDirectory: String
  public var templateDirectoryPath: String?
  public var templateIds: TemplateIds
  public var templatePaths: TemplatePaths
  
  public init(
    anvilApiKey: String = "deadbeef",
    apiBaseUrl: String? = nil,
    configDirectory: String = defaultConfigPath,
    templateDirectorPath: String? = nil,
    templateIds: TemplateIds = .init(),
    templatePaths: TemplatePaths = .init()
  ) {
    self.anvilApiKey = anvilApiKey
    self.apiBaseUrl = apiBaseUrl
    self.configDirectory = configDirectory
    self.templateDirectoryPath = templateDirectorPath
    self.templateIds = templateIds
    self.templatePaths = templatePaths
  }
  
  public var configPath: URL {
    if #available(macOS 13.0, *) {
      return URL(fileURLWithPath: configDirectory, isDirectory: true, relativeTo: .homeDirectory)
        .appendingPathComponent("config.json", conformingTo: .json)
    } else {
      // Fallback on earlier versions
      return URL(
        fileURLWithPath: configDirectory,
        relativeTo: FileManager.default.homeDirectoryForCurrentUser
      ).appendingPathComponent("config.json", conformingTo: .json)
    }
  }
}

public let defaultConfigPath: String = {
  return ProcessInfo.processInfo.environment["XDG_CONFIG_HOME"]
  ?? "~/.config/equipment-selection"
}()

extension CliConfig {
  public struct TemplatePaths: Codable, Equatable, Sendable {
    public var baseInterpolation: String
    public var boiler: String
    public var electric: String
    public var furnace: String
    public var heatPump: String
    public var keyed: String
    public var noInterpolation: String
    public var oneWayIndoor: String
    public var oneWayOutdoor: String
    public var twoWay: String
    
    @inlinable
    public init(
      baseInterpolation: String = "baseInterpolation.json",
      boiler: String = "boiler.json",
      electric: String = "electric.json",
      furnace: String = "furnace.json",
      heatPump: String = "heatPump.json",
      keyed: String = "keyed.json",
      noInterpolation: String = "noInterpolation.json",
      oneWayIndoor: String = "oneWayIndoor.json",
      oneWayOutdoor: String = "oneWayOutdoor.json",
      twoWay: String = "twoWay.json"
    ) {
      self.baseInterpolation = baseInterpolation
      self.boiler = boiler
      self.electric = electric
      self.furnace = furnace
      self.heatPump = heatPump
      self.keyed = keyed
      self.noInterpolation = noInterpolation
      self.oneWayIndoor = oneWayIndoor
      self.oneWayOutdoor = oneWayOutdoor
      self.twoWay = twoWay
    }
  }

  public struct BaseInterpolation: Codable, Equatable, Sendable {
    public var designInfo: DesignInfo
    public var houseLoad: HouseLoad
    public var systemType: SystemType?
    
    @inlinable
    public init(
      designInfo: DesignInfo,
      houseLoad: HouseLoad,
      systemType: SystemType? = nil
    ) {
      self.designInfo = designInfo
      self.houseLoad = houseLoad
      self.systemType = systemType
    }
  }
  
  public struct TemplateIds: Codable, Equatable, Sendable {
    public var noInterpolation: String
    public var oneWayIndoor: String
    public var oneWayOutdoor: String
    public var twoWay: String
    
    @inlinable
    public init(
      noInterpolation: String = "deadbeef",
      oneWayIndoor: String = "deadbeef",
      oneWayOutdoor: String = "deadbeef",
      twoWay: String = "deadbeef"
    ) {
      self.noInterpolation = noInterpolation
      self.oneWayIndoor = oneWayIndoor
      self.oneWayOutdoor = oneWayOutdoor
      self.twoWay = twoWay
    }
  }
}

// MARK: Coding
extension CliConfig {
  
//  public func encode(to encoder: Encoder) throws {
//    var container = encoder.container(keyedBy: CodingKeys.self)
//    try container.encode(anvilApiKey, forKey: .anvilApiKey)
//    try container.encode(apiBaseUrl, forKey: .apiBaseUrl)
//    
//    var configString: String = String(configDirectory.absoluteString
//      .replacingOccurrences(of: "file://", with: "")
////      .split(separator: "\\/")
//    )
//  
//    
//    configString = configString.replacingOccurrences(of: "\\", with: "")
//                            
//    try container.encode("\(configString)", forKey: .configDirectory)
//    
//    try container.encode(templateDirectoryPath, forKey: .templateDirectoryPath)
//    try container.encode(templateIds, forKey: .templateIds)
//    try container.encode(templatePaths, forKey: .templatePaths)
//  }
}
