public enum Navbar: String, CustomStringConvertible {
  case brand
  case expandLarge = "expand-lg"
  case nav
  case scroll
  case text
  case toggler

  @inlinable
  public var description: String { rawValue }
}

public enum Nav: String, CustomStringConvertible {
  case item
  case link
  case pills

  @inlinable
  public var description: String { rawValue }
}
