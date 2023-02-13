import Html
import Models

protocol View {
  func content() async throws -> Node
}

protocol Renderable: View {
  var title: String { get }
}

protocol LinkRepresentable {
  var text: String { get }
  var route: ServerRoute { get }
  var link: Node { get }
}

extension LinkRepresentable {
  var link: Node {
    DocumentMiddlewareLive.link(for: self)
  }
}
