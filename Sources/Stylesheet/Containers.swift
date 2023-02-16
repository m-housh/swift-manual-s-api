public enum Card: String, CustomStringConvertible {
  case body
  case title
  case subtitle

  @inlinable
  public var description: String { rawValue }
}

public enum Dropdown: String, CustomStringConvertible {
  case divider
  case header
  case item
  case menu
  case toggle

  @inlinable
  public var description: String { rawValue }
}

public enum Container: String, CustomStringConvertible {
  case fluid

  @inlinable
  public var description: String { rawValue }
}
