import XCTest
import CustomDump
import Dependencies
import Models
import SiteRouteValidationsLive
import TestSupport

final class SiteRouteValidationTests: XCTestCase {

  func test_twoWay_validations() async throws {
    try await withLiveSiteValidator {
      @Dependency(\.siteValidator) var validator
      var request = ServerRoute.Api.Route.InterpolationRequest.Cooling.TwoWayRequest.zero
      request.manufacturerAdjustments = .airToAir(total: 0, sensible: 0, heating: 0)
      let expected = """
      Two Way Request Errors:
      General:
      (belowDesign.below, designInfo.summer).outdoorTemperature: Below design below outdoorTemperature should be less than the summer design outdoor temperature.
      
      Manufacturer Adjustments:
      manufacturerAdjustments.total: Total adjustment multiplier should be greater than 0.
      manufacturerAdjustments.sensible: Sensible adjustment multiplier should be greater than 0.

      House Load:
      houseLoad.total: Total cooling load should be greater than 0.
      houseLoad.sensible: Sensible cooling load should be greater than 0.
      
      Above Design:
      aboveDesign.above.indoorWetBulb: Above indoor wet-bulb should be greater than 63°.
      aboveDesign.(above, below).indoorWetBulb: Above indoor wet-bulb should be greater than below design indoor wet-bulb.
      aboveDesign.above.cfm: Cfm should be greater than 0.
      aboveDesign.above.indoorTemperature: Indoor temperature should be greater than 0.
      aboveDesign.above.capacity.total: Total capacity should be greater than 0
      aboveDesign.above.capacity.sensible: Sensible capacity should be greater than 0
      aboveDesign.below.cfm: Cfm should be greater than 0.
      aboveDesign.below.indoorTemperature: Indoor temperature should be greater than 0.
      aboveDesign.below.capacity.total: Total capacity should be greater than 0
      aboveDesign.below.capacity.sensible: Sensible capacity should be greater than 0

      Below Design:
      belowDesign.above.indoorWetBulb: Above indoor wet-bulb should be greater than 63°.
      belowDesign.(above, below).indoorWetBulb: Above indoor wet-bulb should be greater than below design indoor wet-bulb.
      belowDesign.above.cfm: Cfm should be greater than 0.
      belowDesign.above.indoorTemperature: Indoor temperature should be greater than 0.
      belowDesign.above.capacity.total: Total capacity should be greater than 0
      belowDesign.above.capacity.sensible: Sensible capacity should be greater than 0
      belowDesign.below.cfm: Cfm should be greater than 0.
      belowDesign.below.indoorTemperature: Indoor temperature should be greater than 0.
      belowDesign.below.capacity.total: Total capacity should be greater than 0
      belowDesign.below.capacity.sensible: Sensible capacity should be greater than 0
      
      
      """

      do {
        try await validator.validate(.api(.init(isDebug: true, route: .interpolate(.cooling(.twoWay(request))))))
      } catch {
        let description = errorString(error)
        XCTAssertNoDifference(expected, description)
      }
    }
  }
  
  func test_oneWay_indoor_validations() async throws {
    try await withLiveSiteValidator {
      @Dependency(\.siteValidator) var validator
      var request = ServerRoute.Api.Route.InterpolationRequest.Cooling.OneWayRequest.zero
      let expected1 = """
      One Way Indoor Request Errors:
      House Load:
      houseLoad.total: Total cooling load should be greater than 0.
      houseLoad.sensible: Sensible cooling load should be greater than 0.
      
      Above Design:
      aboveDesign.indoorWetBulb: Above design indoor wet-bulb should be greater than 63°.
      aboveDesign.cfm: Cfm should be greater than 0.
      aboveDesign.indoorTemperature: Indoor temperature should be greater than 0.
      aboveDesign.capacity.total: Total capacity should be greater than 0
      aboveDesign.capacity.sensible: Sensible capacity should be greater than 0

      Below Design:
      belowDesign.cfm: Cfm should be greater than 0.
      belowDesign.indoorTemperature: Indoor temperature should be greater than 0.
      belowDesign.capacity.total: Total capacity should be greater than 0
      belowDesign.capacity.sensible: Sensible capacity should be greater than 0
      
      
      """
      
      do {
        try await validator.validate(.api(.init(isDebug: true, route: .interpolate(.cooling(.oneWayIndoor(request))))))
      } catch {
        let description = errorString(error)
        XCTAssertNoDifference(expected1, description)
      }
      
      request.aboveDesign.indoorTemperature = 1
      request.aboveDesign.cfm = 1
      request.manufacturerAdjustments = .airToAir(total: 0, sensible: 0, heating: 0)

      // test general errors.
      let expected2 = """
      One Way Indoor Request Errors:
      General:
      (aboveDesign, belowDesign).indoorTemperature: Above design indoor temperature should equal the below design indoor temperature.
      (aboveDesign, belowDesign).cfm: Above design cfm should equal below design cfm.
      
      Manufacturer Adjustments:
      manufacturerAdjustments.total: Total adjustment multiplier should be greater than 0.
      manufacturerAdjustments.sensible: Sensible adjustment multiplier should be greater than 0.

      House Load:
      houseLoad.total: Total cooling load should be greater than 0.
      houseLoad.sensible: Sensible cooling load should be greater than 0.
      
      Above Design:
      aboveDesign.indoorWetBulb: Above design indoor wet-bulb should be greater than 63°.
      aboveDesign.capacity.total: Total capacity should be greater than 0
      aboveDesign.capacity.sensible: Sensible capacity should be greater than 0

      Below Design:
      belowDesign.cfm: Cfm should be greater than 0.
      belowDesign.indoorTemperature: Indoor temperature should be greater than 0.
      belowDesign.capacity.total: Total capacity should be greater than 0
      belowDesign.capacity.sensible: Sensible capacity should be greater than 0


      """

      do {

        try await validator.validate(.api(.init(isDebug: true, route: .interpolate(.cooling(.oneWayIndoor(request))))))
      } catch {
        let description = errorString(error)
        XCTAssertNoDifference(expected2, description)
      }
    }
  }
  
  func test_oneWay_outdoor_validations() async throws {
    try await withLiveSiteValidator {
      @Dependency(\.siteValidator) var validator
      var request = ServerRoute.Api.Route.InterpolationRequest.Cooling.OneWayRequest.zero
      request.manufacturerAdjustments = .airToAir(total: 0, sensible: 0, heating: 0)
      let expected1 = """
      One Way Outdoor Request Errors:
      General:
      (belowDesign, designInfo.summer).outdoorTemperature: Below design outdoor temperature should be less than the summer design outdoor temperature.
      (aboveDesign, designInfo.summer).outdoorTemperature: Above design outdoor temperature should be greater than the summer design outdoor temperature.
      
      Manufacturer Adjustments:
      manufacturerAdjustments.total: Total adjustment multiplier should be greater than 0.
      manufacturerAdjustments.sensible: Sensible adjustment multiplier should be greater than 0.
      
      House Load:
      houseLoad.total: Total cooling load should be greater than 0.
      houseLoad.sensible: Sensible cooling load should be greater than 0.

      Above Design:
      aboveDesign.indoorWetBulb: Above design indoor wet-bulb should equal 63°.
      aboveDesign.cfm: Cfm should be greater than 0.
      aboveDesign.indoorTemperature: Indoor temperature should be greater than 0.
      aboveDesign.capacity.total: Total capacity should be greater than 0
      aboveDesign.capacity.sensible: Sensible capacity should be greater than 0

      Below Design:
      belowDesign.indoorWetBulb: Below design indoor wet-bulb should equal 63°.
      belowDesign.cfm: Cfm should be greater than 0.
      belowDesign.indoorTemperature: Indoor temperature should be greater than 0.
      belowDesign.capacity.total: Total capacity should be greater than 0
      belowDesign.capacity.sensible: Sensible capacity should be greater than 0
      
      
      """
      
      do {
        try await validator.validate(.api(.init(isDebug: true, route: .interpolate(.cooling(.oneWayOutdoor(request))))))
      } catch {
        let description = errorString(error)
        XCTAssertNoDifference(expected1, description)
      }
    }
  }
  
  func test_noInterpolation_validations() async throws {
    try await withLiveSiteValidator {
      @Dependency(\.siteValidator) var validator
      var request = ServerRoute.Api.Route.InterpolationRequest.Cooling.NoInterpolationRequest.zero
      let expected1 = """
      No Interpolation Request Errors:
      Capacity:
      capacity.cfm: Cfm should be greater than 0.
      capacity.indoorTemperature: Indoor temperature should be greater than 0.
      capacity.capacity.total: Total capacity should be greater than 0
      capacity.capacity.sensible: Sensible capacity should be greater than 0
      
      House Load:
      houseLoad.total: Total cooling load should be greater than 0.
      houseLoad.sensible: Sensible cooling load should be greater than 0.
      
      
      """
      
      do {
        try await validator.validate(.api(.init(isDebug: true, route: .interpolate(.cooling(.noInterpolation(request))))))
      } catch {
        let description = errorString(error)
        XCTAssertNoDifference(expected1, description)
      }
      
      // test general errors
      request.capacity.outdoorTemperature = 1
      request.capacity.indoorTemperature = 1
      request.manufacturerAdjustments = .airToAir(total: 0, sensible: 0, heating: 0)
      
      // TODO: - For some reason manufacturer adjustments don't get a new-line seperation??
       let expected2 = """
      No Interpolation Request Errors:
      General:
      (capacity, designInfo.summer).outdoorTemperature: Capacity outdoor temperature should equal the summer design outdoor temperature.
      (capacity, designInfo.summer).indoorTemperature: Capacity indoor temperature should equal the summer design indoor temperature.
      
      Manufacturer Adjustments:
      manufacturerAdjustments.total: Total adjustment multiplier should be greater than 0.
      manufacturerAdjustments.sensible: Sensible adjustment multiplier should be greater than 0.
      
      Capacity:
      capacity.cfm: Cfm should be greater than 0.
      capacity.capacity.total: Total capacity should be greater than 0
      capacity.capacity.sensible: Sensible capacity should be greater than 0
      
      House Load:
      houseLoad.total: Total cooling load should be greater than 0.
      houseLoad.sensible: Sensible cooling load should be greater than 0.
      
      
      """
      do {
        try await validator.validate(.api(.init(isDebug: true, route: .interpolate(.cooling(.noInterpolation(request))))))
      } catch {
        let description = errorString(error)
        XCTAssertNoDifference(expected2, description)
      }
      
    }
  }
  
  func test_boiler_validations() async throws {
    try await withLiveSiteValidator {
      @Dependency(\.siteValidator) var validator
      var request = ServerRoute.Api.Route.InterpolationRequest.Heating.BoilerRequest.zero
      request.altitudeDeratings = .airToAir(total: 0, sensible: 0, heating: 0)
      let expected1 = """
      Boiler Request Errors:
      altitudeDeratings: Heating adjustment multiplier should be greater than 0.
      houseLoad.heating: Heating load should be greater than 0.
      afue: Afue should be greater than 0 or less than 100.
      input: Input should be greater than 0.
      
      """
      
      do {
        try await validator.validate(.api(.init(
          isDebug: true,
          route: .interpolate(.heating(.boiler(request)))
        )))
      } catch {
        let description = errorString(error)
        XCTAssertNoDifference(expected1, description)
      }
    }
  }
  
  func test_furnace_validations() async throws {
    try await withLiveSiteValidator {
      @Dependency(\.siteValidator) var validator
      var request = ServerRoute.Api.Route.InterpolationRequest.Heating.FurnaceRequest.zero
      request.altitudeDeratings = .heating(0)
      let expected1 = """
      Furnace Request Errors:
      altitudeDeratings: Heating adjustment multiplier should be greater than 0.
      houseLoad.heating: Heating load should be greater than 0.
      afue: Afue should be greater than 0 or less than 100.
      input: Input should be greater than 0.
      
      """
      
      do {
        try await validator.validate(.api(.init(
          isDebug: true,
          route: .interpolate(.heating(.furnace(request)))
        )))
      } catch {
        let description = errorString(error)
        XCTAssertNoDifference(expected1, description)
      }
    }
  }
  
  func test_electric_validations() async throws {
    try await withLiveSiteValidator {
      @Dependency(\.siteValidator) var validator
      var request = ServerRoute.Api.Route.InterpolationRequest.Heating.ElectricRequest.zero
      request.heatPumpCapacity = 0
      request.altitudeDeratings = .heating(0)
      let expected1 = """
      Electric Request Errors:
      heatPumpCapacity: Heat pump capacity should be greater than 0.
      altitudeDeratings: Heating adjustment multiplier should be greater than 0.
      inputKW: Input KW should be greater than 0.
      houseLoad.heating: Heating load should be greater than 0.
      
      """
      
      do {
        try await validator.validate(.api(.init(
          isDebug: true,
          route: .interpolate(.heating(.electric(request)))
        )))
      } catch {
        let description = errorString(error)
        XCTAssertNoDifference(expected1, description)
      }
    }
  }
  
  func test_heatPump_validations() async throws {
    try await withLiveSiteValidator {
      @Dependency(\.siteValidator) var validator
      var request = ServerRoute.Api.Route.InterpolationRequest.Heating.HeatPumpRequest.zero
      request.altitudeDeratings = .heating(0)
      let expected1 = """
      Heat Pump Request Errors:
      houseLoad.heating: Heating load should be greater than 0.
      altitudeDeratings: Heating adjustment multiplier should be greater than 0.
      capacity.at47: Capacity at 47° should be greater than 0.
      capacity.at17: Capacity at 47° should be greater than 0.
      
      """
      
      do {
        try await validator.validate(.api(.init(
          isDebug: true,
          route: .interpolate(.heating(.heatPump(request)))
        )))
      } catch {
        let description = errorString(error)
        XCTAssertNoDifference(expected1, description)
      }
    }
  }
  
  func test_thermal_balancePoint_validations() async throws {
    try await withLiveSiteValidator {
      @Dependency(\.siteValidator) var validator
      let request = ServerRoute.Api.Route.BalancePointRequest.Thermal.zero
      let expected1 = """
      Thermal Balance Point Request Errors:
      heatLoss: Heat loss should be greater than 0.
      capacity.at47: Capacity at 47° should be greater than 0.
      capacity.at17: Capacity at 47° should be greater than 0.
      
      """
      
      do {
        try await validator.validate(.api(.init(
          isDebug: true,
          route: .balancePoint(.thermal(request))
        )))
      } catch {
        let description = errorString(error)
        XCTAssertNoDifference(expected1, description)
      }
    }
  }
  
  func test_requiredKW_validations() async throws {
    try await withLiveSiteValidator {
      @Dependency(\.siteValidator) var validator
      var request = ServerRoute.Api.Route.RequiredKWRequest.zero
      request.capacityAtDesign = -1
      let expected1 = """
      Required KW Request Errors:
      heatLoss: Heat loss should be greater than 0.
      capacityAtDesign: Capacity at design should be greater than or equal to 0.
      
      """
      
      do {
        try await validator.validate(.api(.init(
          isDebug: true,
          route: .requiredKW(request)
        )))
      } catch {
        let description = errorString(error)
        XCTAssertNoDifference(expected1, description)
      }
    }
  }
  
  func test_sizingLimit_validations() async throws {
    try await withLiveSiteValidator {
      @Dependency(\.siteValidator) var validator
      var request = ServerRoute.Api.Route.SizingLimitRequest.zero
      request.systemType = .airToAir(type: .airConditioner, compressor: .variableSpeed, climate: .coldWinterOrNoLatentLoad)
      let expected1 = """
      Sizing Limit Request Errors:
      load.cooling.total: Total cooling load should be greater than 0.
      """
      
      do {
        try await validator.validate(.api(.init(
          isDebug: true,
          route: .sizingLimits(request)
        )))
      } catch {
        let description = errorString(error)
        XCTAssertNoDifference(expected1, description)
      }
    }
  }
}
