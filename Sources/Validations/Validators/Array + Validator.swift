

extension Array where Element: Validator {
  
  public var validator: some Validator<Element.Value> {
    ValidationBuilder<Element.Value>._SequenceMany(self)
  }
}
