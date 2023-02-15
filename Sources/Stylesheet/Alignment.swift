public enum Alignment: String, CustomStringConvertible {
  case start = "items-start"

  @inlinable
  public var description: String { rawValue }
}

public enum Justify: String, CustomStringConvertible {
  case end = "contents-end"
  case start = "contents-start"

  @inlinable
  public var description: String { rawValue }
}
