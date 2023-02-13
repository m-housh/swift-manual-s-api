import Dependencies
import Html
import Models
import SiteRouter

func renderInterpolateRoute(_ route: ServerRoute.Documentation.Route.Interpolation) async throws
  -> any Renderable
{
  switch route {
  case .home:
    return InterpolateHome()
  case let .cooling(cooling):
    return renderCooling(cooling)
  case let .heating(heating):
    return renderHeating(heating)
  }
}

struct InterpolateHome: Renderable {

  @Dependency(\.siteRouter) var siteRouter

  let title: String = ServerRoute.Documentation.Route.Key.interpolate.text

  //  var content: Node {
  func content() async throws -> Node {
    .div(
      attributes: [.class("container")],
      .div(
        attributes: [.class("row")],
        [
          .h1("\(title)"),
          _content,
          _links,
        ])
    )
  }

  private var _content: Node {
    .p(
      """
      Add some content here for the \(title) route.
      """)
  }

  private var _links: Node {
    .ul(
      .li(link(for: .documentation(.home), text: "Documentation"))
    )
  }

}
