import Html

func layout(title: String, content: Node) -> Node {
  return [
    .doctype,
    .html(
      .head(
        .meta(name: "viewport", content: "width=device-width, initial-scale=1"),

        .title(title),

        .link(attributes: [
          .rel(.stylesheet),
          .href("https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css"),
        ])

      ),
      .body(
        header,
        .main(content),
        footer,
        .script(attributes: [
          .async(true),
          .src(
            "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"),
        ])
      )
    ),
  ]
}

private let header: Node = [
  .h1("swift-manual-s-api"),
  .blockquote(
    "Api Documentation for manual-s server."
  ),
]

private let footer: Node = [
  .hr,
  .footer("© 2023 Michael Housh"),
]
