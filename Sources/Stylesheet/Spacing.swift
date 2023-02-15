public enum Side: CustomStringConvertible {
  case bottom(Int)
  case end(Int)
  case start(Int)
  case top(Int)

  @inlinable
  public var description: String {
    switch self {
    case let .bottom(bottom):
      return "b-\(bottom)"
    case let .end(end):
      return "e-\(end)"
    case let .start(start):
      return "s-\(start)"
    case let .top(top):
      return "t-\(top)"
    }
  }
}
