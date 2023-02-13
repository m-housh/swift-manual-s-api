import Dependencies
import Foundation
import Html
import Models
import SiteRouter
import URLRouting

func link(for path: ServerRoute, text: any CustomStringConvertible, class: String = "") -> Node {
  @Dependency(\.siteRouter) var siteRouter: AnyParserPrinter<URLRequestData, ServerRoute>
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

// TODO: Remove
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

// TODO: Remove
func content(_ nodes: Node...) -> Node {
  content(nodes)
}

extension Attribute {
  static func data(_ name: SharedString, _ value: SharedString) -> Self {
    .init("data-\(name.description)", value.description)
  }
}

func row(class: SharedString..., content: @escaping () -> Node) -> Node {
  var classString = SharedString.row.description
  classString += " \(`class`.map(\.description).joined(separator: " "))"
  return .div(attributes: [.class(classString)], content())
}

func row(class: (any CustomStringConvertible)..., content: @escaping () -> Node) -> Node {
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

let jsonEncoder: JSONEncoder = {
  let encoder = JSONEncoder()
  encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
  return encoder
}()
