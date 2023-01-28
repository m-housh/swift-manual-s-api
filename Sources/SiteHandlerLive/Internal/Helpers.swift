extension Double {
  static func normalizePercentage(_ value: Double) -> Double {
    (value * 1_000.0).rounded() / 10.0
  }
}
