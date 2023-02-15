import Html

public enum Class: CustomStringConvertible {
  case value(any CustomStringConvertible)

  @inlinable
  public static func align(_ position: Alignment) -> Self {
    .value("align-\(position)")
  }

  @inlinable
  public static func bg(_ colors: BootstrapColor...) -> Self {
    .value("bg-\(colors.description)")
  }

  @inlinable
  public static var border: Self {
    .value("border")
  }

  @inlinable
  public static func border(_ color: BootstrapColor) -> Self {
    .value("border-\(color)")
  }

  @inlinable
  public static var card: Self {
    .value("card")
  }

  @inlinable
  public static func card(_ card: Card) -> Self {
    .value("card-\(card)")
  }

  @inlinable
  public static var col: Self {
    .value("col")
  }

  @inlinable
  public static var container: Self {
    .value("container")
  }

  @inlinable
  public static func container(_ container: Container) -> Self {
    .value("container-\(container)")
  }

  @inlinable
  public static var dropdown: Self {
    .value("dropdown")
  }

  @inlinable
  public static func dropdown(_ dropdown: Dropdown) -> Self {
    .value("dropdown-\(dropdown)")
  }

  @inlinable
  public static var fixedBottom: Self {
    .value("fixed-bottom")
  }

  @inlinable
  public static func justify(_ justify: Justify) -> Self {
    .value("justify-\(justify)")
  }

  @inlinable
  public static func margin(_ side: Side) -> Self {
    .value("m\(side)")
  }

  @inlinable
  public static var nav: Self {
    .value("nav")
  }

  @inlinable
  public static func nav(_ nav: Nav) -> Self {
    .value("nav-\(nav)")
  }

  @inlinable
  public static var navbar: Self {
    .value("navbar")
  }

  @inlinable
  public static func navbar(_ navbar: Navbar) -> Self {
    .value("navbar-\(navbar)")
  }

  @inlinable
  public static func padding(_ side: Side) -> Self {
    .value("p\(side)")
  }

  @inlinable
  public static var row: Self {
    .value("row")
  }

  @inlinable
  public static func text(_ color: BootstrapColor) -> Self {
    .value("text-\(color)")
  }

  @inlinable
  public static func text(_ color: Text) -> Self {
    .value("text-\(color)")
  }
  @inlinable
  public static func text(_ color: BootstrapColor, _ secondary: Text) -> Self {
    .value("text-\(color)-\(secondary)")
  }

  @inlinable
  public var description: String {
    switch self {
    case .value(let value): return value.description
    }
  }

}

extension Attribute {

  @inlinable
  public static func `class`(_ classes: Class...) -> Self {
    .class(classes.map(\.description).joined(separator: " "))
  }
}
