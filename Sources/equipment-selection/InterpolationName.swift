import ArgumentParser
import FirstPartyMocks
import Foundation
import Models

//extension Template.PathKey {
//  var defaultOutputPath: String {
//    "./\(rawValue).json"
//  }
//
//  func parseUrl(url: URL?) -> URL {
//    guard let url else {
//      return URL(fileURLWithPath: defaultOutputPath)
//    }
//    guard url.isFileURL && url.pathExtension == "json" else {
//      return url.appendingPathComponent(defaultOutputPath)
//    }
//    return url
//  }
//}
