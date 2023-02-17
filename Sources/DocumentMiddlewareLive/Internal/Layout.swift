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

    return [
      .div(
        attributes: [.class(.fixedBottom, .bg(.success))],
        .footer(
          attributes: [ /*.class("text-center")*/],
          .p(
            attributes: [
              .class(.text(.light), .fontSize(5), .padding(.top(3)), .margin(.start(5)))
            ],
            "© 2023 Michael Housh"
          )
        )
      )
    ]
  }

}
