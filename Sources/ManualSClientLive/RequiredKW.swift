import Foundation
import Models
import ManualSClient

extension ManualSClient.RequiredKWRequest {
  func run() async throws -> Double {
    let result = (Double(houseLoad.heating) - Double(capacityAtDesign)) / 3413
    return round(result * 100) / 100
  }
}
