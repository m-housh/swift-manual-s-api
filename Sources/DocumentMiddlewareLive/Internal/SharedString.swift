import Html

/// Represents strings that are used in html attributes, such as `class` and `data`.
///
enum SharedString: String, CustomStringConvertible {
  case alignItemsStart
  case bgSuccess
  case bgSuccessSubtle
  case border
  case borderSuccess
  case bsToggle
  case card
  case cardBody
  case cardTitle
  case cardSubtitle
  case container
  case containerFluid
  case dropdown
  case dropdownItem
  case dropdownMenu
  case dropdownToggle
  case fixedBottom
  case justifyContentEnd
  case mb3
  case mb5
  case mt10
  case nav
  case navbar
  case navbarBrand
  case navbarExpandLg
  case navbarNav
  case navItem
  case navLink
  case pb2
  case pb5
  case pt2
  case pt5
  case row
  case textLight
  case textMuted
  case textSecondary

  var description: String {
    switch self {
    case .alignItemsStart:
      return "align-items-start"
    case .bgSuccess:
      return "bg-success"
    case .bgSuccessSubtle:
      return "bg-success-subtle"
    case .bsToggle:
      return "bs-toggle"
    case .borderSuccess:
      return "border-success"
    case .cardBody:
      return "card-body"
    case .cardTitle:
      return "card-title"
    case .cardSubtitle:
      return "card-subtitle"
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
    case .mb3:
      return "mb-3"
    case .mb5:
      return "mb-5"
    case .mt10:
      return "mt-10"
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
    case .pb5:
      return "pb-5"
    case .pt2:
      return "pt-2"
    case .pt5:
      return "pt-5"
    case .textMuted:
      return "text-muted"
    case .textSecondary:
      return "text-secondary"
    case .textLight:
      return "text-light"
    case .container, .row, .nav, .dropdown, .navbar, .border, .card:
      return rawValue

    }
  }
}

extension Attribute {
  static func `class`(_ classStrings: SharedString...) -> Self {
    self.class(classStrings.map(\.description).joined(separator: " "))
  }
}
