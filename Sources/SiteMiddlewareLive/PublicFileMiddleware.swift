import Dependencies
import Logging
import LoggingDependency
import Models
import Vapor

enum PublicFileMiddleware {
  
  static func respond(
    request: Request,
    route: ServerRoute.Public
  ) async throws -> AsyncResponseEncodable {
    
    @Dependency(\.logger) var logger
    
    var path = request.application.directory.publicDirectory
    let filePath: String
    let fileName: String
    var isAttachment = false
    
    switch route {
    case .favicon:
      return try await PublicFileMiddleware.respond(request: request, route: .images(file: "favicon.png"))
    case let .images(file: file):
      fileName = file
      filePath = "images/\(file)"
      path = path.appending(filePath)
    case let .tools(file: file):
      fileName = file
      filePath = "tools/\(file)"
      path = path.appending("tools").appending(file)
      isAttachment = true
    }
    
    let response = request.fileio.streamFile(at: path) { result in
      do {
        try result.get()
      } catch {
        logger.debug(
          """
            Error handling public file.
            Path: \(filePath)
            Error: \(error)
            """
        )
      }
    }
    
    if isAttachment {
      response.headers.contentDisposition = .init(
        .attachment,
        filename: fileName
      )
    } else {
      response.headers.contentType = .png
    }
    return try await response.encodeResponse(for: request)
    
  }
}
