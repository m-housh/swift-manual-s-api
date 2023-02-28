import Foundation
import Models

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Template.Path {

  func parseUrl(url: URL?, with key: Template.PathKey) -> URL {
    guard let url else {
      return URL(fileURLWithPath: self.fileName(for: key))
    }
    return url
  }
}
