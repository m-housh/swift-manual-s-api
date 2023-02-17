public enum Position: String, CustomStringConvertible {
  case absolute
  case fixed
  case relative
  case `static`
  case sticky

  @inlinable
  public var description: String { rawValue }

  public enum Edge: CustomStringConvertible {
    case bottom(Int)
    case end(Int)
    case start(Int)
    case top(Int)

    @inlinable
    public var description: String {
      switch self {
      case let .bottom(bottom):
        return "bottom-\(Constraint(rawValue: bottom) ?? .default)"
      case let .end(end):
        return "end-\(Constraint(rawValue: end) ?? .default)"
      case let .start(start):
        return "start-\(Constraint(rawValue: start) ?? .default)"
      case let .top(top):
        return "top-\(Constraint(rawValue: top) ?? .default)"
      }
    }

    public enum Constraint: Int, CustomStringConvertible {
      case zero = 0
      case fifty = 50
      case oneHundred = 100

      public static let `default`: Self = .zero

      @inlinable
      public var description: String { "\(rawValue)" }
    }
  }
}
