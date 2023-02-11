import Dependencies
import Html
import SiteRouter

func home() -> Node {
  @Dependency(\.siteRouter) var siteRouter: SiteRouter

  return [
    //    .raw("<div class=container>"),
    .div(
      attributes: [.class("container")],
      .div(
        attributes: [.class("row align-items-start")],
        [
          .h1("Home"),
          .p(
            """
              Add some content here.
            """),
          link(for: .documentation(.home), text: "Documentation"),

        ]
      )
    )
  ]
}
