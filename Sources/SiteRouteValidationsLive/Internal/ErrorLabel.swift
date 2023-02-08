
// Holds common error labels used in the validations.
@usableFromInline
enum ErrorLabel: String, CustomStringConvertible {
  case above
  case aboveDesign
  case afue
  case altitudeDeratings
  case at17
  case at47
  case below
  case belowDesign
  case capacity
  case capacityAtDesign
  case cfm
  case cooling
  case designInfo
  case heating
  case heatLoss
  case heatPumpCapacity
  case houseLoad
  case load
  case indoorTemperature
  case indoorWetBulb
  case input
  case inputKW
  case manufacturerAdjustments
  case outdoorTemperature
  case sensible
  case summer
  case total
  
  @usableFromInline
  static var aboveDesignBelow: String {
    self.nest(.aboveDesign, .below)
  }
  
  @usableFromInline
  static var belowDesignBelow: String {
    self.nest(.belowDesign, .below)
  }
  
  @usableFromInline
  static var designInfoSummer: String {
    self.nest(.designInfo, .summer)
  }
}

extension ErrorLabel {
  
  @usableFromInline
  static func nest(_ values: [Self]) -> String {
    values.map { $0.description }.joined(separator: ".")
  }
  
  @usableFromInline
  static func nest(_ values: Self...) -> String {
    nest(values)
  }
  
  @usableFromInline
  static func nest(_ values: (any CustomStringConvertible)...) -> String {
    values.map { $0.description }.joined(separator: ".")
  }
  
  @usableFromInline
  static func parenthesize(_ values: Self...) -> String {
    let inner = values.map { $0.description }.joined(separator: ", ")
    return "(\(inner))"
  }
  
  @usableFromInline
  static func parenthesize(_ values: (any CustomStringConvertible)...) -> String {
    let inner = values.map { $0.description }.joined(separator: ", ")
    return "(\(inner))"
  }
}
