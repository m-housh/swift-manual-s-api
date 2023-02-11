import Dependencies
import Html
import Models
import SiteRouter

protocol Renderable {
  var title: String { get }
  var content: Node { get }
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

func link(for path: ServerRoute, text: String, class: String = "") -> Node {
  @Dependency(\.siteRouter) var siteRouter: SiteRouter
  return .a(
    attributes: [.href(siteRouter.path(for: path)), .class(`class`)],
    .text(text)
  )
}

func link(for value: any LinkRepresentable, class: String = "") -> Node {
  link(for: value.route, text: value.text, class: `class`)
}

func content(_ nodes: [Node]) -> Node {
  var children = nodes[...]
  if nodes.count == 0 {
    children.append(.b("Error."))
  }
  var count = 0
  var div: Node?
  while let node = children.popFirst() {
    count += 1
    if count == 1 {
      div = .div(attributes: [.class("container")], node)
      continue
    }
    div?.append(node)
  }
  return div!

  //  .div(attributes: [.class("container")], nodes[0])
}

func content(_ nodes: Node...) -> Node {
  content(nodes)
}
