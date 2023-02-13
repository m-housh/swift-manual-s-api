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

func link(for path: ServerRoute, text: any CustomStringConvertible, class: String = "") -> Node {
  @Dependency(\.siteRouter) var siteRouter: SiteRouter
  return .a(
    attributes: [.href(siteRouter.path(for: path)), .class(`class`)],
    .text(text.description)
  )
}

func link(for path: ServerRoute, text: any CustomStringConvertible, class strings: SharedString...)
  -> Node
{
  link(for: path, text: text, class: strings.map(\.description).joined(separator: " "))
}

func link(for value: any LinkRepresentable, class: String = "") -> Node {
  link(for: value.route, text: value.text, class: `class`)
}

func link(for key: ServerRoute.Documentation.Route.Key, class strings: SharedString...) -> Node {
  link(for: key, class: strings.map(\.description).joined(separator: " "))
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

extension Attribute {
  static func data(_ name: SharedString, _ value: SharedString) -> Self {
    .init(name.description, value.description)
  }
}

func row(class: SharedString..., content: @escaping () -> Node) -> Node {
  var classString = SharedString.row.description
  classString += " \(`class`.map(\.description).joined(separator: " "))"
  return .div(attributes: [.class(classString)], content())
}

func row(content: @escaping () -> Node) -> Node {
  return .div(attributes: [.class(.row)], content())
}

func container(class: SharedString..., content: @escaping () -> Node) -> Node {
  var classString = SharedString.container.description
  classString += " \(`class`.map(\.description).joined(separator: " "))"
  return .div(attributes: [.class(classString)], content())
}

func container(content: @escaping () -> Node) -> Node {
  return .div(attributes: [.class(.container)], content())
}
