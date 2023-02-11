import Dependencies
import Html
import Models
import SiteRouter

func layout(title: String, content: Node) -> Node {
  return [
    .doctype,
    .html(
      .head(
        .meta(name: "viewport", content: "width=device-width, initial-scale=1"),
        .title(title),
        bootstrapStyleSheet
      ),
      .body(
        navbar,
        .main(content),
        footer,
        bootstrapScript
      )
    ),
  ]
}

func layout(_ renderable: Renderable) -> Node {
  layout(title: renderable.title, content: renderable.content)
}

private var bootstrapStyleSheet: ChildOf<Tag.Head> {
  .link(attributes: [
    .rel(.stylesheet),
    .href("https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css"),
  ])
}

private var bootstrapScript: Node {
  .script(attributes: [
    .async(true),
    .src(
      "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"),
  ])

}

private let footer: Node = [
  .div(
    attributes: [.class("fixed-bottom bg-success")],
    .footer(
      attributes: [ /*.class("text-center")*/],
      .p(attributes: [.class("text-light fs-5 pt-3 ms-5")], "© 2023 Michael Housh")
    )
  )
]

private var navbar: Node {
  @Dependency(\.siteRouter) var siteRouter: SiteRouter

  return .nav(
    attributes: [.class("navbar navbar-expand-lg bg-success text-light")],
    .div(
      attributes: [.class("container-fluid")],
      [
        navbarBrand(siteRouter),
        .div(attributes: [.class("justify-content-end")], documentDropdown(siteRouter)),
      ])
  )
}

private func navbarBrand(_ router: SiteRouter) -> Node {
  .a(
    attributes: [
      .class("navbar-brand text-light"),
      .href(router.path(for: .home)),
    ],
    .text("Home")
  )
}

private func documentDropdown(_ router: SiteRouter) -> Node {

  var documentNavbarItem: Node {
    .ul(
      attributes: [.class("dropdown-menu")],
      [
        .li(link(for: .documentation(.home), text: "Home", class: "dropdown-item")),
        .li(link(for: .balancePoint, class: .dropdownItem)),
        .li(link(for: .derating, class: .dropdownItem)),
        .li(link(for: .interpolate, class: .dropdownItem)),
        .li(link(for: .requiredKW, class: .dropdownItem)),
        .li(link(for: .sizingLimits, class: .dropdownItem)),
      ])
  }

  return .ul(
    attributes: [.class("nav navbar-nav me-auto mb-2 mb-lg-0")],
    [
      .li(
        attributes: [.class("nav-item dropdown")],
        [
          .a(
            attributes: [
              .class("nav-link dropdown-toggle text-light"),
              .role(.button),
              .ariaExpanded(false),
              .data("bs-toggle", "dropdown"),
            ],
            .text("Documentation")
          ),
          documentNavbarItem,
        ])
    ])
}

private func link(for key: ServerRoute.Documentation.Route.Key, class: ClassString) -> Node {
  link(for: key, class: `class`.description)
}

enum ClassString: String, CustomStringConvertible {
  case dropdownItem

  var description: String {
    switch self {
    case .dropdownItem:
      return "dropdown-item"
    }
  }
}
