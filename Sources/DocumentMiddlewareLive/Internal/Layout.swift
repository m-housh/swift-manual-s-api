import Dependencies
import Html
import Models
import SiteRouter
import Stylesheet

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

    // TODO: Add fs to `Class`
    let classString = "\(Class.text(.light)) fs-5 pt-3 ms-5"

    return [
      .div(
        attributes: [.class(.fixedBottom, .bg(.success))],
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
      attributes: [.class(.bg(.success), .navbar, .navbar(.expandLarge), .text(.light))],
      .div(
        attributes: [.class(.container(.fluid))],
        [
          navbarBrand(siteRouter),
          .div(
            attributes: [.class(.justify(.end))],
            documentDropdown(siteRouter)
          ),
        ])
    )
  }

  private static func navbarBrand(_ router: AnyParserPrinter<URLRequestData, ServerRoute>) -> Node {
    .a(
      attributes: [
        .class(.navbar(.brand), .text(.light)),
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
        attributes: [.class(.dropdown(.menu))],
        [
          .li(link(for: .documentation(.home), text: "Home", class: .dropdown(.item))),
          .li(link(for: .balancePoint, class: .dropdown(.item))),
          .li(link(for: .derating, class: .dropdown(.item))),
          .li(link(for: .interpolate, class: .dropdown(.item))),
          .li(link(for: .requiredKW, class: .dropdown(.item))),
          .li(link(for: .sizingLimits, class: .dropdown(.item))),
        ]
      )
    }

    return .ul(
      attributes: [.class(.nav, .navbar(.nav))],
      [
        .li(
          attributes: [.class(.nav(.item), .dropdown)],
          [
            .a(
              attributes: [
                .class(.nav(.link), .dropdown(.toggle), .text(.light)),
                .role(.button),
                .ariaExpanded(false),
                .data("bs-toggle", "dropdown"),  // fix.
              ],
              .text("Documentation")
            ),
            documentNavbarItem,
          ])
      ])
  }
}
