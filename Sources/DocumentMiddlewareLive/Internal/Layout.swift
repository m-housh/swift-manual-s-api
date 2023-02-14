import Dependencies
import Html
import Models
import SiteRouter

func layout(title: String, navbar: Navbar = .init(), content: Node) async throws -> Node {
  return [
    .doctype,
    .html(
      .head(
        .meta(name: "viewport", content: "width=device-width, initial-scale=1"),
        .title(title),
        Layout.bootstrapStyleSheet
      ),
      .body(
        try await navbar.content(),
        .main(content),
        Layout.footer,
        Layout.bootstrapScript
      )
    ),
  ]
}

func layout(_ renderable: Renderable, navbar: Navbar = .init()) async throws -> Node {
  try await layout(title: renderable.title, navbar: navbar, content: renderable.content())
}

private struct Layout {
  @Dependency(\.siteRouter) private static var siteRouter

  private static let bootstrapCss: String =
    "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css"

  static var bootstrapStyleSheet: ChildOf<Tag.Head> {
    .link(attributes: [
      .rel(.stylesheet),
      .href(bootstrapCss),
    ])
  }

  static var bootstrapScript: Node {
    .script(attributes: [
      .async(true),
      .src(
        "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"),
    ])

  }

  static var footer: Node {

    let classString = "\(SharedString.textLight) fs-5 pt-3 ms-5"

    return [
      .div(
        attributes: [.class(.fixedBottom, .bgSuccess)],
        .footer(
          attributes: [ /*.class("text-center")*/],
          .p(
            attributes: [.class(classString)],
            "© 2023 Michael Housh"
          )
        )
      )
    ]
  }

  // TODO: Remove navbar stuff
  static var navbar: Node {

    return .nav(
      attributes: [.class(.bgSuccess, .navbar, .navbarExpandLg, .textLight)],
      .div(
        attributes: [.class(.containerFluid)],
        [
          navbarBrand(siteRouter),
          .div(
            attributes: [.class(.justifyContentEnd)],
            documentDropdown(siteRouter)
          ),
        ])
    )
  }

  private static func navbarBrand(_ router: AnyParserPrinter<URLRequestData, ServerRoute>) -> Node {
    .a(
      attributes: [
        .class(.navbarBrand, .textLight),
        .href(router.path(for: .home)),
      ],
      .text("Home")
    )
  }

  private static func documentDropdown(_ router: AnyParserPrinter<URLRequestData, ServerRoute>)
    -> Node
  {

    var documentNavbarItem: Node {
      .ul(
        attributes: [.class(.dropdownMenu)],
        [
          .li(link(for: .documentation(.home), text: "Home", class: .dropdownItem)),
          .li(link(for: .balancePoint, class: .dropdownItem)),
          .li(link(for: .derating, class: .dropdownItem)),
          .li(link(for: .interpolate, class: .dropdownItem)),
          .li(link(for: .requiredKW, class: .dropdownItem)),
          .li(link(for: .sizingLimits, class: .dropdownItem)),
        ]
      )
    }

    return .ul(
      attributes: [.class(.nav, .navbarNav)],
      [
        .li(
          attributes: [.class(.navItem, .dropdown)],
          [
            .a(
              attributes: [
                .class(.navLink, .dropdownToggle, .textLight),
                .role(.button),
                .ariaExpanded(false),
                .data(.bsToggle, .dropdown),
              ],
              .text("Documentation")
            ),
            documentNavbarItem,
          ])
      ])
  }
}
