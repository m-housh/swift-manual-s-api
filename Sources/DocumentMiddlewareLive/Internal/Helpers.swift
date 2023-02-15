import Dependencies
import Foundation
import Html
import Models
import SiteRouter
import Stylesheet
import URLRouting

// MARK: - Links
func link(for path: ServerRoute, text: any CustomStringConvertible, class: String = "") -> Node {
  @Dependency(\.siteRouter) var siteRouter: AnyParserPrinter<URLRequestData, ServerRoute>
  return .a(
    attributes: [.href(siteRouter.path(for: path)), .class(`class`)],
    .text(text.description)
  )
}

func link(for path: ServerRoute, text: any CustomStringConvertible, class strings: Class...)
  -> Node
{
  link(for: path, text: text, class: strings.map(\.description).joined(separator: " "))
}

func link(for value: any LinkRepresentable, class: String = "") -> Node {
  link(for: value.route, text: value.text, class: `class`)
}

func link(for key: ServerRoute.Documentation.Route.Key, class strings: Class...) -> Node {
  link(for: key, class: strings.map(\.description).joined(separator: " "))
}

// MARK: - Attributes

// TODO: Fix.
extension Attribute {
  static func data(_ name: Class, _ value: Class) -> Self {
    .init("data-\(name.description)", value.description)
  }
}

// MARK: - Row

func row(class: Class..., content: @escaping () -> Node) -> Node {
  var classString = Class.row.description
  classString += " \(`class`.map(\.description).joined(separator: " "))"
  return .div(attributes: [.class(classString)], content())
}

func row(class: (any CustomStringConvertible)..., content: @escaping () -> Node) -> Node {
  var classString = Class.row.description
  classString += " \(`class`.map(\.description).joined(separator: " "))"
  return .div(attributes: [.class(classString)], content())
}

func row(content: @escaping () -> Node) -> Node {
  return .div(attributes: [.class(.row)], content())
}

// MARK: - Container

func container(class: Class..., content: @escaping () -> Node) -> Node {
  var classString = Class.container.description
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
