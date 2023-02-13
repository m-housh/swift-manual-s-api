import Html

/// Represents strings that are used in html attributes, such as `class` and `data`.
///
enum SharedString: String, CustomStringConvertible {
  case alignItemsStart
  case bgSuccess
  case border
  case borderSuccess
  case bsToggle
  case container
  case containerFluid
  case dropdown
  case dropdownItem
  case dropdownMenu
  case dropdownToggle
  case fixedBottom
  case justifyContentEnd
  case mb5
  case nav
  case navbar
  case navbarBrand
  case navbarExpandLg
  case navbarNav
  case navItem
  case navLink
  case pb2
  case pt2
  case row
  case textLight
  case textSecondary

  var description: String {
    switch self {
    case .alignItemsStart:
      return "align-items-start"
    case .bgSuccess:
      return "bg-success"
    case .bsToggle:
      return "bs-toggle"
    case .borderSuccess:
      return "border-success"
    case .containerFluid:
      return "container-fluid"
    case .dropdownItem:
      return "dropdown-item"
    case .dropdownMenu:
      return "dropdown-menu"
    case .dropdownToggle:
      return "dropdown-toggle"
    case .fixedBottom:
      return "fixed-bottom"
    case .justifyContentEnd:
      return "justify-content-end"
    case .mb5:
      return "mb-5"
    case .navbarBrand:
      return "navbar-brand"
    case .navbarExpandLg:
      return "navbar-expand-lg"
    case .navItem:
      return "nav-item"
    case .navLink:
      return "nav-link"
    case .navbarNav:
      return "navbar-nav"
    case .pb2:
      return "pb-2"
    case .pt2:
      return "pt-2"
    case .textSecondary:
      return "text-secondary"
    case .textLight:
      return "text-light"
    case .container, .row, .nav, .dropdown, .navbar, .border:
      return rawValue

    }
  }
}

extension Attribute {
  static func `class`(_ classStrings: SharedString...) -> Self {
    self.class(classStrings.map(\.description).joined(separator: " "))
  }
}
