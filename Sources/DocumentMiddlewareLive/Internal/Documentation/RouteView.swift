import ApiRouteMiddleware
import Dependencies
import Html
import LoggingDependency
import Models
import ValidationMiddleware

#warning("use userDefaults for baseURL")
struct RouteView {
  @Dependency(\.apiMiddleware) var apiMiddleware
  @Dependency(\.baseURL) var baseURL
  @Dependency(\.logger) var logger
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.validationMiddleware) var validationMiddleware

  let json: AnyEncodable
  let route: ServerRoute.Api.Route
  let title: String
  let description: Node
  let inputDescription: Node
  let failingJson: ServerRoute.Api.Route

  init(
    json: any Encodable,
    route: ServerRoute.Api.Route,
    title: String,
    description: Node,
    inputDescription: Node,
    failingJson: ServerRoute.Api.Route
  ) {
    self.json = json.eraseToAnyEncodable()
    self.route = route
    self.title = title
    self.description = description
    self.inputDescription = inputDescription
    self.failingJson = failingJson
  }

  enum IdKey: String, CaseIterable {
    case input
    case output
    case route
    case validation
    case navigation

    var id: String { rawValue }
    var linkId: String { "#\(id)" }

    var description: String {
      let value = rawValue.capitalized
      switch self {
      case .input, .output, .validation:
        return value.appending("s")
      case .route, .navigation:
        return value
      }
    }
  }
}

extension RouteView: Renderable {
  func content() async throws -> Node {
    let body = try await body()
    return container {
      row {
        [
          routeNav,
          .div(
            attributes: [.class(.col(8))],
            [
              row(class: .padding(.top(2))) {
                [
                  .h1("\(title)"),
                  .hr(attributes: [.class(.border, .border(.success))]),
                ]
              },
              .div(
                attributes: [
                  .class(.padding(.start(2))),
                  .data("bs-spy", "scroll"),
                  .data("bs-target", IdKey.navigation.linkId),
                  .tabindex(0),

                ],
                body
              ),
            ]
          ),
        ]

      }
    }
  }

  private var routeNavLinks: [Node] {
    IdKey.allCases.compactMap { id in
      guard id != .navigation else { return nil }
      return Node.a(
        attributes: [.class(.nav(.link), .padding(2)), .href(id.linkId)],
        .text(id.description)
      )
    }
  }

  private var routeNav: Node {
    .div(
      attributes: [
        .class(.col(2), .bg(.light), .card, .position(.sticky), .top(50)),
        .style(safe: "height: 200px;"),
        .id(IdKey.navigation.description),
      ],
      routeNavLinks.reduce(
        into: Node.nav(attributes: [.class(.nav, .nav(.pills), .flex(.column))])
      ) { nav, link in
        nav.append(link)
      }
    )
  }

  private func body() async throws -> Node {
    let jsonOutput = try await jsonOutput()
    let failingOutput = await failingJson()
    var node: Node = [
      row(class: .padding(.top(2))) {
        description
      },
      row(class: .padding(.top(3))) {
        [
          heading("Route:", id: .route),
          .code(
            attributes: [.class(.fontSize(6))],
            .pre([.text("POST "), .text(routeString)])
          ),
        ]
      },
      row(class: .padding(.top(2))) {
        [
          heading("JSON Input Example:", id: .input),
          row(class: .align(.start)) {
            [
              row(class: .col) {
                inputDescription
              },
              row(class: .col) {
                .code(
                  attributes: [.class(.fontSize(6))],
                  .pre(.text(jsonString))
                )
              },
            ]
          },
        ]
      },
      row(class: .padding(.top(2)), .margin(.bottom(title == "Derating" ? 5 : 0))) {
        [
          heading("JSON Output Example:", id: .output),
          .code(
            attributes: [.class(.fontSize(6))],
            .pre(.text(jsonOutput))
          ),
        ]
      },

    ]

    if title != "Derating" {
      node.append(
        row(class: .padding(.top(2)), .margin(.bottom(5))) {
          [
            heading("Validation Errors", id: .validation),
            .p("The following is an example of errors if the inputs are not appropriate."),
            .pre(attributes: [.class(.text(.danger), .fontSize(6))], .text(failingOutput)),
          ]
        }
      )
    }

    return node
  }
}

// MARK: - Helpers

extension RouteView {

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

  private func heading(_ string: String, id: IdKey) -> Node {
    .h3(attributes: [.class(.text(.secondary)), .id(id.id)], .text(string))
  }

  private func failingJson() async -> String {
    do {
      try await validationMiddleware.validate(.api(.init(isDebug: false, route: failingJson)))
      logger.warning(
        """
        Failed to fetch validation output.

        Route: \(routeString)
        """)
      return "Failed to fetch validations"
    } catch {
      return "\(error)"
    }
  }
}
