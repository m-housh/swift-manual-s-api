import Models
import Foundation

struct OneWayIndoorAnvilTemplate: Codable {
  let title: String
  let fontSize: Int
  let textColor: String
  let data: Data
  
  struct Data: Codable {
    let customerName: String
    let customerAddress: String
    let summerOutdoorDesignTemperature: Int
    let customerCity: String
    let customerState: String
    let customerZipCode: Int
    let systemID: String
    let summerIndoorDesignTemperature: Int
    let summerIndoorDesignHumidity: Double
    let winterOutdoorDesignTemperature: Int
    let projectElevation: Int
    let systemType: String
    let furnaceManufacturer: String
    let ahuOrCoilManufacturer: String
    let condenserManufacturer: String
    let packageManufacturer: String
    let furnaceModel: String
    let ahuOrCoilModel: String
    let condenserModel: String
    let packageModel: String
    let afue: Int
    let seer: Int
    let hspf: Int
    let fanSpeed: String
    let heatLoad: Int
    let heatAdjustmentMultiplier: Int
    let coolingTotalLoad: Int
    let coolingSensibleLoad: Int
    let coolingLatentLoad: Int
    let coolingSHR: Double
    let coolingTotalAdjustmentMultiplier: Double
    let coolingSensibleAdjustmentMultiplier: Double
    let outdoorBelowDesignTemperature: Int
    let indoorBelowDesignTemperature: Int
    let belowDesignCFM: Int
    let aboveDesignWetBulb: Int
    let belowDesignTotalBTU: Int
    let belowDesignSensibleBTU: Int
    let belowDesignLatentBTU: Int
    let belowDesignSHR: Double
    let belowDesignAdjustedTotalBTU: Int
    let belowDesignAdjustedSensibleBTU: Int
    let belowDesignWetBulb: Int
    let belowDesignInterpolatedTotalBTU: Int
    let belowDesignInterpolatedSensibeBTU: Int
    let belowDesignInterpolatedLatentBTU: Int
    let belowDesignInterpolatedSHR: Double
    let indoorAboveDesignTemperature: Int
    let outdoorAboveDesignTemperature: Int
    let aboveDesignCFM: Int
    let aboveDesignTotalBTU: Int
    let aboveDesignSensibleBTU: Int
    let aboveDesignLatentBTU: Int
    let aboveDesignSHR: Double
    let aboveDesignInterpolatedSHR: Double
    let aboveDesignAdjustedTotalBTU: Int
    let aboveDesignInterpolatedTotalBTU: Int
    let aboveDesignInterpolatedSensibeBTU: Int
    let aboveDesignInterpolatedLatentBTU: Int
    let indoorFinalDesignTemperature: Int
    let outdoorFInalDesignTemperature: Int
    let interpolatedDesignTotalBTU: Int
    let interpolatedDesignSensibleBTU: Int
    let interpolatedDesignLatentBTU: Int
    let interpolatedDesignSHR: Double
    let excessLatent: Int
    let finalInterpolatedDesignSensibleBTU: Int
    let finalInterpolatedDesignLatentBTU: Int
    let coolingTotalAltitudeAdjustmentMultiplier: Double
    let coolingSensibleAltitudeAdjustmentMultiplier: Double
    let finalSHR: Double
    let finalTotalBTU: Int
    let finalSensibeBTU: Int
    let finalLatentBTU: Int
    let coolingTotalOversizingLimit: Double
    let coolingLatentOversizingLimit: Double
    let totalCapacityOfDesign: Double
    let latentCapacityOfDesign: Double
    let sensibleCapacityOfDesign: Double
    let finalInterpolatedDesignSHR: Double
  }
}

struct ConversionError: Error { }

extension OneWayIndoorAnvilTemplate {
  
  init(
    request: ServerRoute.Api.Route.Interpolation.Cooling.OneWay,
    result: InterpolationResponse.Result
  ) throws {
    
    guard case let .cooling(cooling) = result,
          case let .cooling(oversizingLimits) = cooling.result.sizingLimits.oversizing
    else {
      throw ConversionError()
    }
    
    self.init(
      title: "Manual S",
      fontSize: 10,
      textColor: "#333333",
      data: .init(
        customerName: "FIX ME",
        customerAddress: "1234 FIX ME Street",
        summerOutdoorDesignTemperature: request.designInfo.summer.outdoorTemperature,
        customerCity: "FIX ME",
        customerState: "FIX ME",
        customerZipCode: 12345,
        systemID: "FIX ME",
        summerIndoorDesignTemperature: request.designInfo.summer.indoorTemperature,
        summerIndoorDesignHumidity: Double(request.designInfo.summer.indoorHumidity),
        winterOutdoorDesignTemperature: request.designInfo.winter.outdoorTemperature,
        projectElevation: request.designInfo.elevation,
        systemType: request.systemType.label,
        furnaceManufacturer: "FIX ME",
        ahuOrCoilManufacturer: "FIX ME",
        condenserManufacturer: "FIX ME",
        packageManufacturer: "FIX ME",
        furnaceModel: "FIX ME",
        ahuOrCoilModel: "FIX ME",
        condenserModel: "FIX ME",
        packageModel: "FIX ME",
        afue: 12345,
        seer: 12345,
        hspf: 12345,
        fanSpeed: "FIX ME",
        heatLoad: request.houseLoad.heating,
        heatAdjustmentMultiplier: 1, // fix me
        coolingTotalLoad: request.houseLoad.cooling.total,
        coolingSensibleLoad: request.houseLoad.cooling.sensible,
        coolingLatentLoad: request.houseLoad.cooling.latent,
        coolingSHR: request.houseLoad.cooling.sensibleHeatRatio,
        coolingTotalAdjustmentMultiplier: 1, // fix me
        coolingSensibleAdjustmentMultiplier: 1, // fix me
        outdoorBelowDesignTemperature: request.belowDesign.outdoorTemperature,
        indoorBelowDesignTemperature: request.belowDesign.indoorTemperature,
        belowDesignCFM: request.belowDesign.cfm,
        aboveDesignWetBulb: request.belowDesign.indoorWetBulb,
        belowDesignTotalBTU: request.belowDesign.capacity.total,
        belowDesignSensibleBTU: request.belowDesign.capacity.sensible,
        belowDesignLatentBTU: request.belowDesign.capacity.sensible,
        belowDesignSHR: request.belowDesign.capacity.sensibleHeatRatio,
        belowDesignAdjustedTotalBTU: request.belowDesign.capacity.total, // fix me
        belowDesignAdjustedSensibleBTU: request.belowDesign.capacity.sensible, // fix me
        belowDesignWetBulb: request.belowDesign.indoorWetBulb,
        belowDesignInterpolatedTotalBTU: 1, // fix me
        belowDesignInterpolatedSensibeBTU: 1, // fix me
        belowDesignInterpolatedLatentBTU: 1, // fix me
        belowDesignInterpolatedSHR: 0.1, // fix me
        indoorAboveDesignTemperature: request.aboveDesign.indoorTemperature,
        outdoorAboveDesignTemperature: request.aboveDesign.outdoorTemperature,
        aboveDesignCFM: request.aboveDesign.cfm,
        aboveDesignTotalBTU: request.aboveDesign.capacity.total,
        aboveDesignSensibleBTU: request.aboveDesign.capacity.sensible,
        aboveDesignLatentBTU: request.aboveDesign.capacity.latent,
        aboveDesignSHR: request.aboveDesign.capacity.sensibleHeatRatio,
        aboveDesignInterpolatedSHR: 1, // fix me
        aboveDesignAdjustedTotalBTU: 1, // fix me
        aboveDesignInterpolatedTotalBTU: 1, // fix me
        aboveDesignInterpolatedSensibeBTU: 1, // fix me
        aboveDesignInterpolatedLatentBTU: 1, // fix me
        indoorFinalDesignTemperature: request.designInfo.summer.indoorTemperature,
        outdoorFInalDesignTemperature: request.designInfo.summer.outdoorTemperature,
        interpolatedDesignTotalBTU: cooling.result.interpolatedCapacity.total,
        interpolatedDesignSensibleBTU: cooling.result.interpolatedCapacity.sensible,
        interpolatedDesignLatentBTU: cooling.result.interpolatedCapacity.latent,
        interpolatedDesignSHR: cooling.result.interpolatedCapacity.sensibleHeatRatio,
        excessLatent: cooling.result.excessLatent,
        finalInterpolatedDesignSensibleBTU: cooling.result.finalCapacityAtDesign.total,
        finalInterpolatedDesignLatentBTU: 1, // fix me
        coolingTotalAltitudeAdjustmentMultiplier: 1, // fix me
        coolingSensibleAltitudeAdjustmentMultiplier: 1, // fix me
        finalSHR: cooling.result.finalCapacityAtDesign.sensibleHeatRatio,
        finalTotalBTU: cooling.result.finalCapacityAtDesign.total,
        finalSensibeBTU: cooling.result.finalCapacityAtDesign.sensible,
        finalLatentBTU: cooling.result.finalCapacityAtDesign.latent,
        coolingTotalOversizingLimit: Double(oversizingLimits.total),
        coolingLatentOversizingLimit: Double(oversizingLimits.latent),
        totalCapacityOfDesign: cooling.result.capacityAsPercentOfLoad.total,
        latentCapacityOfDesign: cooling.result.capacityAsPercentOfLoad.latent,
        sensibleCapacityOfDesign: cooling.result.capacityAsPercentOfLoad.sensible,
        finalInterpolatedDesignSHR: cooling.result.finalCapacityAtDesign.sensibleHeatRatio
      )
    )
  }
}

struct AnvilKeyNotFound: Error { }

func apiRequest(_ template: OneWayIndoorAnvilTemplate) async throws -> (Data, URLResponse) {
  var request = URLRequest(url: URL(string: "https://app.useanvil.com/api/v1/fill/MP60yOfB4EWSrq0DOGwn.pdf")!)
  request.httpMethod = "POST"
  request.httpBody = try JSONEncoder().encode(template)
  request.setValue("application/json", forHTTPHeaderField: "Content-Type")
  guard let apiKey = ProcessInfo.processInfo.environment["ANVIL_API_KEY"] else {
    throw AnvilKeyNotFound()
  }
  let b64Auth = Data("\(apiKey)".utf8).base64EncodedString()
  let authString = "Basic \(b64Auth)"
  request.setValue(authString, forHTTPHeaderField: "Authorization")
  return try await URLSession.shared.data(for: request)
}
