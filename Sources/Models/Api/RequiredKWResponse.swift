public struct RequiredKWResponse: Codable, Equatable {

  public let requiredKW: Double

  public init(requiredKW: Double) {
    self.requiredKW = requiredKW
  }
}
