import Dependencies
import Foundation
import Models
import URLRouting

public struct SiteRouter: ParserPrinter {

  public var encoder: JSONEncoder
  public var decoder: JSONDecoder

  public init(
    decoder: JSONDecoder,
    encoder: JSONEncoder
  ) {
    self.encoder = encoder
    self.decoder = decoder
  }

  @ParserBuilder
  public var body: AnyParserPrinter<URLRequestData, ServerRoute> {
    OneOf {
      Route(.case(ServerRoute.home))

      Route(.case(ServerRoute.documentation)) {
        Path { ServerRoute.Key.documentation.key }
        DocumentRouter()
      }

      Route(.case(ServerRoute.api)) {
        Path { ServerRoute.Key.api.key }
        Parse(.memberwise(ServerRoute.Api.init(isDebug:route:))) {
          Headers {
            Field("X-DEBUG", default: false) { Bool.parser() }
          }
          ApiRouter(decoder: self.decoder, encoder: self.encoder)
        }
      }
    }
    .eraseToAnyParserPrinter()

  }

  public func print(
    _ output: Models.ServerRoute,
    into input: inout URLRouting.URLRequestData
  ) throws {
    try self.body.print(output, into: &input)
  }

  public func parse(
    _ input: inout URLRouting.URLRequestData
  ) throws -> Models.ServerRoute {
    try self.body.parse(&input)
  }
}

extension SiteRouter: DependencyKey {

  public static var testValue: SiteRouter {
    .init(decoder: .init(), encoder: jsonEncoder)
  }

  public static var liveValue: SiteRouter {
    .init(decoder: .init(), encoder: jsonEncoder)
  }
}

extension DependencyValues {

  public var siteRouter: SiteRouter {
    get { self[SiteRouter.self] }
    set { self[SiteRouter.self] = newValue }
  }
}

private let jsonEncoder: JSONEncoder = {
  var encoder = JSONEncoder()
  encoder.outputFormatting = .sortedKeys
  return encoder
}()

typealias CoolingKey = ServerRoute.Documentation.Route.Interpolation.Cooling
typealias HeatingKey = ServerRoute.Documentation.Route.Interpolation.Heating
typealias InterpolationKey = ServerRoute.Documentation.Route.Interpolation.Key
typealias RouteKey = ServerRoute.Documentation.Route.Key
