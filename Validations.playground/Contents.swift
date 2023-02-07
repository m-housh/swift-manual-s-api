import Foundation

struct User {
  let name: String
  let email: String
  let deeply = Deeply()
  
  struct Deeply {
    
    let nested = Nested()
    
    struct Nested {
      let value: Int = 10
    }
  }
}

let keyPath = \User.deeply.nested.value

// works  on top-level items, but does not reflect keys of deeply nested values.
func key<Value: Equatable>(for keyPath: KeyPath<User, Value>, with user: User) -> String {
  
  let mirror = Mirror(reflecting: user)
  let value = user[keyPath: keyPath]
  var label: String = ""
  
  for child in mirror.children {
    if value == child.value as? Value, let childLabel = child.label {
      label = childLabel
      break
    }
  }
  
  return label
}

let user = User(name: "blob", email: "blob@example.com")

print(key(for: keyPath, with: user))
