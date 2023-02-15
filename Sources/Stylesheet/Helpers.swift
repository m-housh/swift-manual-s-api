extension Array where Element: RawRepresentable, Element.RawValue: CustomStringConvertible {

  @usableFromInline
  var description: String {
    map(\.rawValue.description).joined(separator: "-")
  }
}
