public struct CapacityAsPercentOfLoad: Codable, Equatable, Sendable {

  public var total: Double
  public var sensible: Double
  public var latent: Double

  public init(total: Double, sensible: Double, latent: Double) {
    self.total = total
    self.sensible = sensible
    self.latent = latent
  }
}
