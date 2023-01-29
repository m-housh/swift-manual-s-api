public struct ValidationError: Error, Equatable {
  public let message: String
  
  @inlinable
  public init(message: String) {
    self.message = message
  }
}
