public struct CoolingCapacity: Codable, Equatable, Sendable {

  /// The total cooling capacity.
  public var total: Int

  /// The sensible cooling capacity.
  public var sensible: Int

  /// Create a new cooling capacity instance.
  ///
  /// - Parameters:
  ///   - total: The total cooling capacity.
  ///   - sensible: The sensible cooling capacity.
  public init(
    total: Int,
    sensible: Int
  ) {
    self.total = total
    self.sensible = sensible
  }

  /// The latent cooling.
  public var latent: Int { total - sensible }

  /// The calculated sensible heat ratio.
  public var sensibleHeatRatio: Double {
    guard total > 0, sensible > 0 else { return 0 }
    return Double(sensible) / Double(total)
  }

  /// Creates a cooling load with the values set to zero.
  public static var zero: Self {
    .init(total: 0, sensible: 0)
  }
}

/// Represents the manufacturer's cooling capacity data.
///
///
public struct ManufactuerCoolingCapacity: Codable, Equatable, Sendable {
  
  /// The manufacturer's cfm for the capacity.
  public var cfm: Int
  
  /// The indoor temperature for the manufacturer's capacity.
  public var indoorTemperature: Int
  
  /// The indoor wet-bulb temperature for the manufacturer's capacity.
  public var indoorWetBulb: Int
  
  /// The outdoor temperature for the manufacturer's capacity.
  public var outdoorTemperature: Int
  
  /// The cooling capacity from the manufacturer.
  public var capacity: CoolingCapacity

  /// Create a new manufacturer's cooling capacity.
  ///
  /// - Parameters:
  ///   - cfm: The cfm for the capacity.
  ///   - indoorTemperature: The indoor temperature for the capacity.
  ///   - indoorWetBulb: The indoor wet-bulb temperature for the capacity.
  ///   - outdoorTemperature: The outdoor temperature for the capacity.
  ///   - capacity: The cooling capacity.
  public init(
    cfm: Int,
    indoorTemperature: Int,
    indoorWetBulb: Int,
    outdoorTemperature: Int,
    capacity: CoolingCapacity
  ) {
    self.cfm = cfm
    self.indoorTemperature = indoorTemperature
    self.indoorWetBulb = indoorWetBulb
    self.outdoorTemperature = outdoorTemperature
    self.capacity = capacity
  }
}
