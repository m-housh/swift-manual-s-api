import Dependencies
import Html

struct Home: Renderable {

  var title: String { Key.home.description }

  init() {}

  func content() async throws -> Node {
    container {
      [
        row(class: .alignItemsStart) {
          [
            .h1("\(title)"),
            .hr(attributes: [.class(.border, .borderSuccess)])
          ]
        },
        body
      ]
    }
  }

  private var body: Node {
      row {
        [
          .p(
          """
            Manual-S is used by heating and cooling professionals and designers to ensure the selected
            equipment is sized appropriately for the house load and design conditions.
            """
          ),
          .br,
          .p(
          """
            Because design conditions and manufacturer's cooling and heating data sets vary, you must choose
            the interpolation type that matches your criteria.
            """
          ),
          .br,
          .p(
          """
            The api routes provided can be used to interpolate manufacturer's heating and cooling data sets and provide
            results of the capacity at your design conditions, offering pass / fail results based on sizing limits set forth
            in the ACCA Manual-S 2014 edition for your given design conditions.
            """
          ),
          .br,
          .p("Follow the link below to learn about the API routes provided."),
          link(for: .documentation(.home), text: Key.documentation)
        ]
      }
  }

  enum Key: String, CustomStringConvertible {
    case documentation
    case home

    var description: String {
      switch self {
      case .home:
        return "Manual-S API"
      case .documentation:
        return rawValue.capitalized
      }
    }
  }
}
