
public struct AnyEncodable: Encodable {
  
  public let value: any Encodable
  
  public init(value: any Encodable) {
    self.value = value
  }
  
  public func encode(to encoder: Encoder) throws {
    try value.encode(to: encoder)
  }
}

extension Encodable {
  
  public func eraseToAnyEncodable() -> AnyEncodable {
    .init(value: self)
  }
}
