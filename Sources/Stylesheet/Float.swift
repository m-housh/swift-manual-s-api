public enum Float: String, CustomStringConvertible {
  case end
  case none
  case start

  @inlinable
  public var description: String { rawValue }
}
