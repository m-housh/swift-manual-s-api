import XCTest
import ManualSClient
import ManualSClientLive

final class HeatingInterpolationTests: XCTestCase {
  
  let client = ManualSClient.live
  
  func test_furnace() async throws {
    let request = ManualSClient.HeatingInterpolation.FurnaceRequest(
      altitudeDeratings: nil,
      houseLoad: .mock,
      input: 60_000,
      afue: 96
    )
    let sut = try await client.interpolate(.heating(.furnace(request)))
    XCTAssertEqual(sut, .heating(.furnace(.init(request: request, outputCapacity: 57_600, finalCapacity: 57_600, percentOfLoad: 116))))
  }
  
  func test_furnace_fails() async {
    await XCTAssertThrowsError(try await client.interpolate(.heating(.furnace(.init(
      houseLoad: .mock, input: 0, afue: 96))))
    )
    await XCTAssertThrowsError(try await client.interpolate(.heating(.furnace(.init(
      houseLoad: .mock, input: 10_000, afue: 0))))
    )
    await XCTAssertThrowsError(try await client.interpolate(.heating(.furnace(.init(
      houseLoad: .mock, input: 10_000, afue: 101))))
    )
  }
  
  func test_boiler() async throws {
    let request = ManualSClient.HeatingInterpolation.BoilerRequest(
      altitudeDeratings: nil,
      houseLoad: .mock,
      input: 60_000,
      afue: 96
    )
    let sut = try await client.interpolate(.heating(.boiler(request)))
    XCTAssertEqual(sut, .heating(.boiler(.init(request: request, outputCapacity: 57_600, finalCapacity: 57_600, percentOfLoad: 116))))
  }
  
  func test_electric_no_heatPump() async throws {
    let request = ManualSClient.HeatingInterpolation.ElectricRequest(
      altitudeDeratings: nil,
      houseLoad: .mock,
      inputKW: 15
    )
    let sut = try await client.interpolate(.heating(.electric(request)))
    XCTAssertEqual(sut, .heating(.electric(.init(request: request, requiredKW: 14.55, percentOfLoad: 103.1))))
  }
  
  func test_electric_fails() async {
    await XCTAssertThrowsError(try await client.interpolate(.heating(.electric(.init(houseLoad: .mock, inputKW: 0)))))
  }
  
  func test_heatPump() async throws {
    let request = ManualSClient.HeatingInterpolation.HeatPumpRequest(
      altitudeDeratings: nil,
      capacity: .mock,
      designInfo: .init(),
      houseLoad: .mock
    )
    let sut = try await client.interpolate(.heating(.heatPump(request)))
    XCTAssertEqual(sut, .heating(.heatPump(.init(request: request, finalCapacity: .mock, capacityAtDesign: 11_308, balancePointTemperature: 38.5, requiredKW: 11.24))))
  }
}

extension XCTest {
  func XCTAssertThrowsError<T: Sendable>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (_ error: Error) -> Void = { _ in }
  ) async {
    do {
      _ = try await expression()
      XCTFail(message(), file: file, line: line)
    } catch {
      errorHandler(error)
    }
  }
}
