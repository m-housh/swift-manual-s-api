public enum Text: String, CustomStringConvertible {

  case black
  case body
  case emphasis
  case muted
  case tertiary
  case white

  @inlinable
  public var description: String { rawValue }
}
