import Dependencies
import Html
import Models
import SiteRouter

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
    var contentDiv = Node.div(attributes: [.class(.containerFluid)], navbarBrand)
    if let contents {
      contentDiv.append(contents)
      //      contentDiv.append(
      //        .div(attributes: [.class(.justifyContentEnd)], contents)
      //      )
    }
    return .nav(
      attributes: [.class(.bgSuccess, .navbar, .navbarExpandLg, .textLight)],
      contentDiv
    )
  }

  @usableFromInline
  var navbarBrand: Node {
    .a(
      attributes: [
        .class(.navbarBrand, .textLight),
        .href(router.path(for: .home)),
      ],
      .text("Home")
    )
  }

  @usableFromInline
  static var routesDropdown: Node {

    let dropdownItem = Node.ul(
      attributes: [.class(.dropdownMenu), .style(safe: "margin-left:-40px;")],
      [
        .li(link(for: .interpolate, class: .dropdownHeader, .dropdownItem)),
        .li(link(interpolation: .cooling)),
        .li(link(interpolation: .heating)),
        .dropdownDivider,
        .dropdownHeader("Utilities"),
        .li(link(for: .balancePoint, class: .dropdownItem)),
        .li(link(for: .derating, class: .dropdownItem)),
        .li(link(for: .requiredKW, class: .dropdownItem)),
        .li(link(for: .sizingLimits, class: .dropdownItem)),
      ]
    )

    let dropdownList = Node.ul(
      attributes: [.class(.nav, .navbarNav)],
      .li(
        attributes: [.class(.navItem, .dropdown)],
        [
          .a(
            attributes: [
              .class(.navLink, .dropdownToggle, .textLight),
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

    return .div(attributes: [.class("justify-content-end pe-5")], dropdownList)
  }
}

private func link(interpolation: ServerRoute.Documentation.Route.Interpolation.Key) -> Node {
  link(for: interpolation, class: "dropdown-item")
}

private func link(cooling: ServerRoute.Documentation.Route.Interpolation.Cooling) -> Node {
  link(for: cooling, class: "dropdown-item")
}

extension ChildOf<Tag.Ul> {
  @usableFromInline
  static var dropdownDivider: Self {
    .li(.hr(attributes: [.class("dropdown-divider")]))
  }

  @inlinable
  static func dropdownHeader(_ string: String) -> Self {
    .li(attributes: [.class("dropdown-header")], .h6(.text(string)))
  }
}
