
public struct BalancePointResponse: Codable, Equatable {
  public let balancePoint: Double
  
  public init(balancePoint: Double) {
    self.balancePoint = balancePoint
  }
}
