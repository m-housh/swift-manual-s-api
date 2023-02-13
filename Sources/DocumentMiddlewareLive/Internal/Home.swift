import Dependencies
import Html
import SiteRouter

struct Home: Renderable {

  @Dependency(\.siteRouter) private var siteRouter

  var title: String { Key.home.description }

  init() {}

  //  var content: Node {
  func content() async throws -> Node {
    container {
      row(class: .alignItemsStart) {
        [
          .h1("\(title)"),
          .hr(attributes: [.class(.border, .borderSuccess)]),
          body,
          link(for: .documentation(.home), text: Key.documentation),
        ]

      }
    }
  }

  private var body: Node {
    [
      row {
        .p(
          """
          Add some content here.
          """
        )
      }
    ]
  }

  enum Key: String, CustomStringConvertible {
    case documentation
    case home

    var description: String {
      switch self {
      case .home, .documentation:
        return rawValue.capitalized
      }
    }
  }
}
