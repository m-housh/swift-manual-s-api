public enum ColorMode: String {
  case light
  case dark
}

public enum BootstrapColor: String, CustomStringConvertible {
  case danger
  case dark
  case info
  case light
  case primary
  case secondary
  case subtle
  case success
  case warning

  @inlinable
  public var description: String { rawValue }
}
