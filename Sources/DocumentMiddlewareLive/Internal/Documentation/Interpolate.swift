import Dependencies
import Html
import Models
import SiteRouter

struct InterpolateHome: Renderable {

  @Dependency(\.siteRouter) var siteRouter: SiteRouter

  let title: String = ServerRoute.Documentation.Route.Key.interpolate.text

  var content: Node {
    .div(attributes: [.class("container")],
      .div(attributes: [.class("row")], [
        .h1("\(title)"),
        _content,
        _links
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

func renderInterpolateRoute(_ route: ServerRoute.Documentation.Route.Interpolation) -> Node {
  switch route {
  case .home:
    return layout(InterpolateHome())
  case .cooling(_):
    return layout(InterpolateHome()) // fix.
  case .heating(_):
    return layout(InterpolateHome()) // fix.
  }
}
