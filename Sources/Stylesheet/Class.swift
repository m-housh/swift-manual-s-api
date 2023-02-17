import Html

public struct Class: CustomStringConvertible {

  @usableFromInline
  var value: any CustomStringConvertible

  @inlinable
  public init(_ value: any CustomStringConvertible) {
    self.value = value
  }

  @inlinable
  public static func align(_ position: Alignment) -> Self {
    .init("align-\(position)")
  }

  @inlinable
  public static func align(_ side: Alignment.Side) -> Self {
    self.align(.items(side))
  }

  @inlinable
  public static func bg(_ colors: BootstrapColor...) -> Self {
    .init("bg-\(colors.description)")
  }

  @inlinable
  public static var border: Self {
    .init("border")
  }

  @inlinable
  public static func border(_ color: BootstrapColor) -> Self {
    .init("border-\(color)")
  }

  @inlinable
  public static func border(_ side: Alignment.Side) -> Self {
    .init("border-\(side)")
  }

  @inlinable
  public static var card: Self {
    .init("card")
  }

  @inlinable
  public static func card(_ card: Card) -> Self {
    .init("card-\(card)")
  }

  @inlinable
  public static var col: Self {
    .init("col")
  }

  @inlinable
  public static func col(_ col: Int) -> Self {
    .init("col-\(col)")
  }

  @inlinable
  public static var container: Self {
    .init("container")
  }

  @inlinable
  public static func container(_ container: Container) -> Self {
    .init("container-\(container)")
  }

  @inlinable
  public static var dropdown: Self {
    .init("dropdown")
  }

  @inlinable
  public static func dropdown(_ dropdown: Dropdown) -> Self {
    .init("dropdown-\(dropdown)")
  }

  @inlinable
  public static var fixedBottom: Self {
    .init("fixed-bottom")
  }

  @inlinable
  public static func flex(_ flex: Flex) -> Self {
    .init("flex-\(flex)")
  }

  @inlinable
  public static func float(_ float: Float) -> Self {
    .init("float-\(float)")
  }

  @inlinable
  public static func fontSize(_ size: Int) -> Self {
    let size = Text.Size(rawValue: size) ?? .default
    return fontSize(size)
  }

  @inlinable
  public static func fontSize(_ size: Text.Size) -> Self {
    return .init("fs-\(size)")
  }

  @inlinable
  public static func justify(_ justify: Alignment) -> Self {
    .init("justify-\(justify)")
  }

  @inlinable
  public static func justify(_ side: Alignment.Side) -> Self {
    self.justify(.contents(side))
  }

  @inlinable
  public static func margin(_ side: Side) -> Self {
    .init("m\(side)")
  }

  @inlinable
  public static var nav: Self {
    .init("nav")
  }

  @inlinable
  public static func nav(_ nav: Nav) -> Self {
    .init("nav-\(nav)")
  }

  @inlinable
  public static var navbar: Self {
    .init("navbar")
  }

  @inlinable
  public static func navbar(_ navbar: Navbar) -> Self {
    .init("navbar-\(navbar)")
  }

  @inlinable
  public static func padding(_ side: Side) -> Self {
    .init("p\(side)")
  }

  @inlinable
  public static func padding(_ value: Int) -> Self {
    .init("p-\(Side.Size(rawValue: value) ?? .auto)")
  }

  @inlinable
  public static func position(_ position: Position) -> Self {
    .init("position-\(position)")
  }

  @inlinable
  public static var row: Self {
    .init("row")
  }

  @inlinable
  public static var stickyTop: Self {
    .init("sticky-top")
  }

  @inlinable
  public static func text(_ color: BootstrapColor) -> Self {
    .init("text-\(color)")
  }

  @inlinable
  public static func text(_ color: Text) -> Self {
    .init("text-\(color)")
  }

  @inlinable
  public static func text(_ color: BootstrapColor, _ secondary: Text) -> Self {
    .init("text-\(color)-\(secondary)")
  }

  @inlinable
  public static func top(_ top: Int) -> Self {
    .init(Position.Edge.top(top).description)
  }

  @inlinable
  public var description: String { value.description }

}

extension Attribute {

  @inlinable
  public static func `class`(_ classes: Class...) -> Self {
    .class(classes.map(\.description).joined(separator: " "))
  }
}
