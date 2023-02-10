/// Represents the response from a required kilowatt api request.
///
public struct RequiredKWResponse: Codable, Equatable {

  /// The calculated required kilowatts.
  public let requiredKW: Double

  /// Create a new required kilowatt response container.
  ///
  /// - Parameters:
  ///   - requiredKW: The calculated required kilowatts.
  public init(requiredKW: Double) {
    self.requiredKW = requiredKW
  }
}
