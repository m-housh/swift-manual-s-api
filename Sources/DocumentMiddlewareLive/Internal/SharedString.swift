import Html

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
  case nav
  case navbar
  case navbarBrand
  case navbarExpandLg
  case navbarNav
  case navItem
  case navLink
  case row
  case textLight

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
