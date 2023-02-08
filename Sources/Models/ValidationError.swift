public struct ValidationError: Error {
  let message: String

  public init(_ message: String) {
    self.message = message
  }
}
