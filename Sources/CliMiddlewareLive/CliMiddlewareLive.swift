@_exported import CliMiddleware
import Dependencies

extension CliMiddleware: DependencyKey {

  public static var liveValue: CliMiddleware {
    .init(
      config: CliMiddleware.ConfigContext.run(context:),
      templates: CliMiddleware.TemplateContext.run(context:),
      validate: CliMiddleware.ValidationContext.run(context:)
    )
  }
}
