import ApiRouteMiddleware
import Dependencies
import Html
import Models

struct RouteView {
  @Dependency(\.apiMiddleware) var apiMiddleware
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.baseURL) var baseURL

  let json: AnyEncodable
  let route: ServerRoute.Api.Route
  let title: String
  let description: Node

  init(
    json: any Encodable,
    route: ServerRoute.Api.Route,
    title: String,
    description: String
  ) {
    self.json = json.eraseToAnyEncodable()
    self.route = route
    self.title = title
    self.description = .p(.text(description))
  }

  init(
    json: any Encodable,
    route: ServerRoute.Api.Route,
    title: String,
    description: Node
  ) {
    self.json = json.eraseToAnyEncodable()
    self.route = route
    self.title = title
    self.description = description
  }

  private var jsonString: String {
    guard let data = try? jsonEncoder.encode(json),
      let string = String(data: data, encoding: .utf8)
    else {
      return "Oops, something went wrong."
    }
    return string
  }

  private var routeString: String {
    let path = siteRouter.path(for: .api(.init(isDebug: false, route: route)))
    return "\(baseURL)\(path)"
  }

  private func jsonOutput() async throws -> String {
    let output = try await apiMiddleware.respond(.init(isDebug: false, route: route))
    guard let data = try? jsonEncoder.encode(output),
      let string = String(data: data, encoding: .utf8)
    else {
      return "Oops, something went wrong."
    }
    return string
  }

  private func body() async throws -> Node {
    let jsonOutput = try await jsonOutput()
    return [
      row(class: .pt2) {
        description
      },
      row(class: "pt-3") {
        [
          heading("Route:"),
          .code(.pre([.text("POST "), .text(routeString)])),
        ]
      },
      row(class: .pt2) {
        [
          heading("JSON Input Example:"),
          .code(.pre(.text(jsonString))),
        ]
      },
      row(class: .pt2, .mb5, .pb5) {
        [
          heading("JSON Output Example:"),
          .code(.pre(.text(jsonOutput))),
        ]
      },
    ]
  }

  private func heading(_ string: String) -> Node {
    .h3(attributes: [.class(.textSecondary)], .text(string))
  }
}

extension RouteView: Renderable {

  //  var content: Node {
  func content() async throws -> Node {
    let body = try await body()
    return container {
      [
        row(class: .pt2) {
          [
            .h1("\(title)"),
            .hr(attributes: [.class(.border, .borderSuccess)]),
          ]
        },
        body,
      ]
    }
  }
}
