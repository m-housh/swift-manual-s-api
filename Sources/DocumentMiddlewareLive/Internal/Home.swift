import Dependencies
import Html
import SiteRouter

func home() -> Node {
  @Dependency(\.siteRouter) var siteRouter: SiteRouter

  return [
    .h1("Swift Manual-S API"),
    .p(
      """
      Add some content here.
      """),
    .a(
      attributes: [
        .href(siteRouter.path(for: .documentation(.home)))
      ],
      .text("documentation")
    ),
  ]
}
