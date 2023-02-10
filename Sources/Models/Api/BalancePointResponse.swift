/// Represents the response from a balance point api request.
public struct BalancePointResponse: Codable, Equatable {

  /// The calculated balance point temperature.
  public let balancePoint: Double

  /// Create a new balance point container.
  ///
  /// - Parameters:
  ///   - balancePoint: The calculated balance point.
  public init(balancePoint: Double) {
    self.balancePoint = balancePoint
  }
}
