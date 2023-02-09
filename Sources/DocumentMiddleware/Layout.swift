import Html

func layout(title: String, content: Node) -> Node {
  return [
    .doctype,
    .html(
      .head(
        .title(title),

        // Bootstrap style-sheet
        .link(attributes: [
          .rel(.stylesheet),
          .href("https://stackpath.bootstrapcdn.com/bootswatch/4.3.1/cerulean/bootstrap.min.css"),
        ])
      ),
      .body(
        header,
        .main(content),
        footer,
        .script(attributes: [
          .async(true),
          .src("https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"),
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
