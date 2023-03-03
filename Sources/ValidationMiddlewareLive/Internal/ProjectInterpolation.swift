import Models
import Validations

extension Project: AsyncValidatable {

  public var body: some AsyncValidation<Self> {
    AsyncValidator.accumulating {
      AsyncValidator.validate(\.houseLoad, with: HouseLoadValidator(style: .cooling))
        .errorLabel("House Load")

      AsyncValidator.validate(\.interpolations)
        .errorLabel("Systems")
    }
  }
}

extension Array: AsyncValidation where Element: AsyncValidation, Element.Value == Element {

  public func validate(_ value: Self) async throws {
    var errors: [Error] = []
    for element in value {
      do {
        try await element.validate(element)
      } catch {
        errors.append(error)
      }
    }
    guard errors.isEmpty else {
      throw AccumulatedError(errors: errors)
    }
  }
}

extension Array: AsyncValidatable where Element: AsyncValidatable {
  public func validate() async throws {
    try await self.validate(self)
  }
}

private struct AccumulatedError: Error, CustomDebugStringConvertible {
  let errors: [Error]

  var debugDescription: String {
    String(errors.map({ "\($0)" }).joined(separator: "\n"))
  }
}
