import ApiRouteMiddleware
import Dependencies
import Html
import LoggingDependency
import Models

// TODO: Add validation errors, currently thinking that we use an
// invalid value and printing the error.
struct RouteView {
  @Dependency(\.apiMiddleware) var apiMiddleware
  @Dependency(\.baseURL) var baseURL
  @Dependency(\.logger) var logger
  @Dependency(\.siteRouter) var siteRouter

  let json: AnyEncodable
  let route: ServerRoute.Api.Route
  let title: String
  let description: Node
  let inputDescription: Node

  init(
    json: any Encodable,
    route: ServerRoute.Api.Route,
    title: String,
    description: Node,
    inputDescription: Node
  ) {
    self.json = json.eraseToAnyEncodable()
    self.route = route
    self.title = title
    self.description = description
    self.inputDescription = inputDescription
  }

  private var jsonString: String {
    guard let data = try? jsonEncoder.encode(json),
      let string = String(data: data, encoding: .utf8)
    else {
      logger.warning(
        """
        Failed to parse json string.

        Route: \(routeString)
        """)
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
      logger.warning(
        """
        Failed to parse json output.

        Route: \(routeString)
        """)
      return "Oops, something went wrong."
    }
    return string
  }

  private func heading(_ string: String) -> Node {
    .h3(attributes: [.class(.text(.secondary))], .text(string))
  }
}

extension RouteView: Renderable {
  func content() async throws -> Node {
    let body = try await body()
    return container {
      [
        row(class: .padding(.top(2))) {
          [
            .h1("\(title)"),
            .hr(attributes: [.class(.border, .border(.success))]),
          ]
        },
        body,
      ]
    }
  }

  private func body() async throws -> Node {
    let jsonOutput = try await jsonOutput()
    return [
      row(class: .padding(.top(2))) {
        description
      },
      row(class: .padding(.top(3))) {
        [
          heading("Route:"),
          .code(
            attributes: [.class(.fontSize(5))],
            .pre([.text("POST "), .text(routeString)])
          ),
        ]
      },
      row(class: .padding(.top(2))) {
        [
          heading("JSON Input Example:"),
          row(class: .align(.start)) {
            [
              row(class: .col) {
                inputDescription
              },
              row(class: .col) {
                .code(
                  attributes: [.class(.fontSize(5))],
                  .pre(.text(jsonString))
                )
              },
            ]
          },
        ]
      },
      row(class: .padding(.top(2)), .padding(.bottom(5)), .margin(.bottom(5))) {
        [
          heading("JSON Output Example:"),
          .code(
            attributes: [.class(.fontSize(5))],
            .pre(.text(jsonOutput))
          ),
        ]
      },
    ]
  }

}
