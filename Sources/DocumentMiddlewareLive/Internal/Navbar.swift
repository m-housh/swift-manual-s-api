import Dependencies
import Html
import Models
import SiteRouter
import Stylesheet

@usableFromInline
struct Navbar: View {
  @Dependency(\.siteRouter) var router

  @usableFromInline
  var contents: Node?

  @inlinable
  init(contents: Node? = nil) {
    self.contents = contents
  }

  @usableFromInline
  func content() async throws -> Node {
    var contentDiv = Node.div(attributes: [.class(.container(.fluid))], self.navbarBrand)
    if let contents {
      contentDiv.append(contents)
    }
    return .nav(
      attributes: [
        .class(.bg(.success), .navbar, .navbar(.expandLarge), .text(.light), .stickyTop)
      ],
      contentDiv
    )
  }

  @usableFromInline
  var navbarBrand: Node {
    .a(
      attributes: [
        .class(.navbar(.brand), .text(.light)),
        .href(router.path(for: .home)),
      ],
      .text("Home")
    )
  }

  @usableFromInline
  static var routesDropdown: Node {

    let dropdownItem = Node.ul(
      attributes: [.class(.dropdown(.menu)), .style(safe: "margin-left:-40px;")],
      [
        .li(link(for: .interpolate, class: .dropdown(.header), .dropdown(.item))),
        .li(link(interpolation: .cooling)),
        .li(link(interpolation: .heating)),
        .dropdownDivider,
        .dropdownHeader("Utilities"),
        .li(link(for: .balancePoint, class: .dropdown(.item))),
        .li(link(for: .derating, class: .dropdown(.item))),
        .li(link(for: .requiredKW, class: .dropdown(.item))),
        .li(link(for: .sizingLimits, class: .dropdown(.item))),
      ]
    )

    let dropdownList = Node.ul(
      attributes: [.class(.nav, .navbar(.nav))],
      .li(
        attributes: [.class(.nav(.item), .dropdown)],
        [
          .a(
            attributes: [
              .class(.nav(.link), .dropdown(.toggle), .text(.light)),
              .role(.button),
              .ariaExpanded(false),
              .data(.bsToggle, .dropdown),
            ],
            .text("Routes")
          ),
          dropdownItem,
        ]
      )
    )

    return .div(
      attributes: [.class(.justify(.end), .padding(.end(5)))],
      dropdownList
    )
  }
}

private func link(interpolation: ServerRoute.Documentation.Route.Interpolation.Key) -> Node {
  link(for: interpolation, class: .dropdown(.item))
}

private func link(cooling: ServerRoute.Documentation.Route.Interpolation.Cooling) -> Node {
  link(for: cooling, class: .dropdown(.item))
}

extension ChildOf<Tag.Ul> {
  @usableFromInline
  static var dropdownDivider: Self {
    .li(.hr(attributes: [.class(.dropdown(.divider))]))
  }

  @inlinable
  static func dropdownHeader(_ string: String) -> Self {
    .li(attributes: [.class(.dropdown(.header))], .h6(.text(string)))
  }
}
