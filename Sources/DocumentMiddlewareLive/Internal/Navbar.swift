import Dependencies
import Html
import Models
import SiteRouter

struct Navbar: View {
  @Dependency(\.siteRouter) var router
  
  var contents: Node?
  
  init(contents: Node? = nil) {
    self.contents = contents
  }
  
  func content() async throws -> Node {
    var contentDiv = Node.div(attributes: [.class(.containerFluid)], navbarBrand)
    if let contents {
      contentDiv.append(contents)
    }
    return .nav(
      attributes: [.class(.bgSuccess, .navbar, .navbarExpandLg, .textLight)],
      contentDiv
    )
  }
  
  
  private var navbarBrand: Node {
    .a(
      attributes: [
        .class(.navbarBrand, .textLight),
        .href(router.path(for: .home))
      ],
      .text("Home")
    )
  }
}
