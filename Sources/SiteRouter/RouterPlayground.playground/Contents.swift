import FirstPartyMocks
import Foundation
import Models

let model = Project.mock
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

let encoded = try encoder.encode(model)

print(String(data: encoded, encoding: .utf8)!)

let decoded = try JSONDecoder().decode(Project.self, from: encoded)
assert(decoded == model)
