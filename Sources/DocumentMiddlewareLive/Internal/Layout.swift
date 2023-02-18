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
        .meta(name: "theme-color", content: "#ffffff"),
        .meta(name: "msapplication-TileColor", content: "#da532c"),
        .title(title),
        .link(
          attributes: [
            .rel(.appleTouchIcon),
            .type(.image(.png)),
            .sizes("180x180"),
            .href("/public/images?file=apple-touch-icon.png"),
          ]
        ),
        .link(
          attributes: [
            .rel(.appleTouchIconPrecomposed),
            .type(.image(.png)),
            .sizes("180x180"),
            .href("/public/images?file=apple-touch-icon.png"),
          ]
        ),
        .link(
          attributes: [
            .rel(.icon),
            .type(.image(.png)),
            .sizes("32x32"),
            .href("/public/images?file=favicon-32x32.png"),
          ]
        ),
        .link(
          attributes: [
            .rel(.icon),
            .type(.image(.png)),
            .sizes("16x16"),
            .href("/public/images?file=favicon-16x16.png"),
          ]
        ),
        .link(
          attributes: [
            .rel(.maskIcon),
            .href("/public/images?file=safari-pinned-tab.svg"),
            .color("#5bbad5"),
          ]
        ),
        .link(
          attributes: [
            .rel(.manifest),
            .href("/site.webmanifest"),
          ]
        ),
        Layout.bootstrapStyleSheet
      ),
      .body(
        attributes: [
          //          .data("bs-spy", "scroll"),
          //          .data("bs-target", "#navigation"),
          //          .tabindex(0)
        ],
        try await navbar.content(),
        container {
          .main(content)
        },
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

extension Attribute.Rel {
  public static var appleTouchIcon: Self {
    .init(rawValue: "apple-touch-icon")
  }

  public static var appleTouchIconPrecomposed: Self {
    .init(rawValue: "apple-touch-icon-precomposed")
  }

  public static var maskIcon: Self {
    .init(rawValue: "mask-icon")
  }

  public static var manifest: Self {
    .init(rawValue: "manifest")
  }
}

extension Attribute {
  public static func sizes(_ value: String) -> Self {
    .init("sizes", value)
  }

  public static func color(_ value: String) -> Self {
    .init("color", value)
  }
}
