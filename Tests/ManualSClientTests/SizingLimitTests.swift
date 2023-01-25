import Models
import ManualSClientLive
import ManualSClient
import XCTest

final class SizingLimitTests: XCTestCase {
  
  let client = ManualSClient.live
  
  func test_cooling_mildWinterOrLatentLoad() async throws {
    let suts: [(SystemType, SizingLimits)] = [
      (
        .airToAir(type: .heatPump, compressor: .singleSpeed, climate: .mildWinterOrLatentLoad),
        .init(oversizing: .cooling(total: 115, latent: 150), undersizing: .cooling(total: 90, sensible: 90, latent: 90))
      ),
      (
        .airToAir(type: .airConditioner, compressor: .singleSpeed, climate: .mildWinterOrLatentLoad),
        .init(oversizing: .cooling(total: 115, latent: 150), undersizing: .cooling(total: 90, sensible: 90, latent: 90))
      ),
      (
        .airToAir(type: .heatPump, compressor: .multiSpeed, climate: .mildWinterOrLatentLoad),
        .init(oversizing: .cooling(total: 120, latent: 150), undersizing: .cooling(total: 90, sensible: 90, latent: 90))
      ),
      (
        .airToAir(type: .airConditioner, compressor: .multiSpeed, climate: .mildWinterOrLatentLoad),
        .init(oversizing: .cooling(total: 120, latent: 150), undersizing: .cooling(total: 90, sensible: 90, latent: 90))
      ),
      (
        .airToAir(type: .heatPump, compressor: .variableSpeed, climate: .mildWinterOrLatentLoad),
        .init(oversizing: .cooling(total: 130, latent: 150), undersizing: .cooling(total: 90, sensible: 90, latent: 90))
      ),
      (
        .airToAir(type: .airConditioner, compressor: .variableSpeed, climate: .mildWinterOrLatentLoad),
        .init(oversizing: .cooling(total: 130, latent: 150), undersizing: .cooling(total: 90, sensible: 90, latent: 90))
      )
    ]
    
    // MARK: Test
    for (systemType, expected) in suts {
      let sut = try await client.sizingLimits(systemType: systemType)
      XCTAssertEqual(sut, expected)
    }
  }
  
  func test_cooling_coldWinterOrNoLatentLoad() async throws {
    let suts: [(SystemType, SizingLimits)] = [
      (
        .airToAir(type: .heatPump, compressor: .singleSpeed, climate: .coldWinterOrNoLatentLoad),
        .init(oversizing: .cooling(total: 184, latent: 150), undersizing: .cooling(total: 90, sensible: 90, latent: 90))
      ),
      (
        .airToAir(type: .airConditioner, compressor: .singleSpeed, climate: .coldWinterOrNoLatentLoad),
        .init(oversizing: .cooling(total: 184, latent: 150), undersizing: .cooling(total: 90, sensible: 90, latent: 90))
      ),
      (
        .airToAir(type: .heatPump, compressor: .multiSpeed, climate: .coldWinterOrNoLatentLoad),
        .init(oversizing: .cooling(total: 184, latent: 150), undersizing: .cooling(total: 90, sensible: 90, latent: 90))
      ),
      (
        .airToAir(type: .airConditioner, compressor: .multiSpeed, climate: .coldWinterOrNoLatentLoad),
        .init(oversizing: .cooling(total: 184, latent: 150), undersizing: .cooling(total: 90, sensible: 90, latent: 90))
      ),
      (
        .airToAir(type: .heatPump, compressor: .variableSpeed, climate: .coldWinterOrNoLatentLoad),
        .init(oversizing: .cooling(total: 184, latent: 150), undersizing: .cooling(total: 90, sensible: 90, latent: 90))
      ),
      (
        .airToAir(type: .airConditioner, compressor: .variableSpeed, climate: .coldWinterOrNoLatentLoad),
        .init(oversizing: .cooling(total: 184, latent: 150), undersizing: .cooling(total: 90, sensible: 90, latent: 90))
      )
    ]

    // MARK: Test
    for (systemType, expected) in suts {
      let sut = try await client.sizingLimits(systemType, .mock)
      XCTAssertEqual(sut, expected)
    }
  }
  
  func test_cooling_coldWinterOrNoLatentLoad_throws_error() async throws {
    
    do {
      _ = try await client.sizingLimits(
        .airToAir(type: .airConditioner, compressor: .variableSpeed, climate: .coldWinterOrNoLatentLoad),
        nil
      )
      XCTFail()
    } catch {
      XCTAssertTrue(true)
    }
    
  }
  
  func test_furnace() async throws {
    let sut = try await client.sizingLimits(.furnaceOnly, nil)
    XCTAssertEqual(sut, .init(oversizing: .furnace(140), undersizing: .furnace(90)))
  }
  
  
  func test_boiler() async throws {
    let sut = try await client.sizingLimits(.boilerOnly, nil)
    XCTAssertEqual(sut, .init(oversizing: .boiler(140), undersizing: .boiler(90)))
  }
}