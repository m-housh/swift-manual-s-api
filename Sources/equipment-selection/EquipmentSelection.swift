import ArgumentParser

// TODO: Add a validation command to check files

@main
struct EquipmentSelection: AsyncParsableCommand {

  static var configuration = CommandConfiguration(
    abstract: "A utility for performing equipment selection requests.",
    subcommands: [
      Config.self,
      Interpolate.self,
      Template.self,
      Validate.self,
    ]
  )
}
