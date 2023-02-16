public enum Alignment: CustomStringConvertible {

  case items(Side)
  case contents(Side)

  @inlinable
  public var description: String {
    switch self {
    case let .items(items):
      return "items-\(items)"
    case let .contents(contents):
      return "contents-\(contents)"
    }
  }

  public enum Side: String, CustomStringConvertible {
    case end
    case start

    @inlinable
    public var description: String { rawValue }
  }
}

//public enum Justify: String, CustomStringConvertible {
//  case end = "contents-end"
//  case start = "contents-start"
//
//  @inlinable
//  public var description: String { rawValue }
//}
