import Dependencies
import Foundation
import Html
import Models
import SiteRouter
import URLRouting

// MARK: - Links
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

// MARK: - Attributes

extension Attribute {
  static func data(_ name: SharedString, _ value: SharedString) -> Self {
    .init("data-\(name.description)", value.description)
  }
}

// MARK: - Row

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

// MARK: - Container

func container(class: SharedString..., content: @escaping () -> Node) -> Node {
  var classString = SharedString.container.description
  classString += " \(`class`.map(\.description).joined(separator: " "))"
  return .div(attributes: [.class(classString)], content())
}

func container(content: @escaping () -> Node) -> Node {
  return .div(attributes: [.class(.container)], content())
}

// MARK: - JSON Encoder
let jsonEncoder: JSONEncoder = {
  let encoder = JSONEncoder()
  encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
  return encoder
}()

// MARK: - Card

func card(body: [(String, String)]) -> Node {
  let bodyNode = body.map({ (title, description) -> ChildOf<Tag.Ul> in
    .li(
      attributes: [.class("list-group-item pb-3 ps-2")],
      [
        Node.pre(attributes: [.class("text-secondary fs-6 mb-0 pt-2")], .text(title)),
        Node.text(description),
      ]
    )
  })
  .reduce(into: Node.ul(attributes: [.class("list-group list-group-flush")])) {
    $0.append($1.rawValue)
  }

  return .div(
    attributes: [.class("card bg-success-subtle")],
    bodyNode
  )
}
