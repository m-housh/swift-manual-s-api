/// Represents a side used for padding and margins.
///
public enum Side: CustomStringConvertible {
  case bottom(Int)
  case end(Int)
  case start(Int)
  case top(Int)
  
  @inlinable
  public var description: String {
    let prefix: String
    let size: Size?
    
    switch self {
    case let .bottom(bottom):
      prefix = "b"
      size = .init(rawValue: bottom)
    case let .end(end):
      prefix = "e"
      size = .init(rawValue: end)
    case let .start(start):
      prefix = "s"
      size = .init(rawValue: start)
    case let .top(top):
      prefix = "t"
      size = .init(rawValue: top)
    }
    
    return "\(prefix)-\(size ?? .default)"
  }
  
  /// Represents a valid size value for padding or margins.
  ///
  /// Generally not used directly, but this type ensures that padding or margin values are
  /// appropriate or defaults them `auto`.
  public enum Size: Int, CustomStringConvertible {
    case zero = 0
    case one
    case two
    case three
    case four
    case five
    case auto
    
    @inlinable
    public static var `default`: Self { .auto }
    
    @inlinable
    public var description: String {
      switch self {
      case .zero, .one, .two, .three, .four, .five:
        return "\(rawValue)"
      case .auto:
        return "auto"
      }
    }
  }
}
