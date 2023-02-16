public enum Text: String, CustomStringConvertible {

  case black
  case body
  case emphasis
  case muted
  case tertiary
  case white

  @inlinable
  public var description: String { rawValue }
  
  public enum Size: Int, CustomStringConvertible {
    case one = 1
    case two
    case three
    case four
    case five
    case six
    
    @inlinable
    public static var `default`: Self { .six }
    
    @inlinable
    public var description: String { "\(rawValue)" }
  }
}
