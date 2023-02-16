import Html

public enum DataAttribute: String, CustomStringConvertible {
  case bsToggle = "bs-toggle"

  @inlinable
  public var description: String { rawValue }

  public enum Value: String, CustomStringConvertible {
    case dropdown

    @inlinable
    public var description: String { rawValue }
  }
}

extension Attribute {

  @inlinable
  public static func data(_ name: DataAttribute, _ value: DataAttribute.Value) -> Self {
    .init("data-\(name.description)", value.description)
  }
}
