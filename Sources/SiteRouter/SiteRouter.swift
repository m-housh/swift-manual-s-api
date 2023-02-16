import Dependencies
import Foundation
import Models
@_exported import URLRouting

public struct SiteRouter: ParserPrinter {

  //  @Dependency(\.baseURL) var baseURL

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

      Route(.case(ServerRoute.public(file:))) {
        Path { "public" }
        Query {
          Field("file")
        }
        //        Parse(.memberwise(<#T##(Values) -> Struct#>))
      }

      // matches /api/v1
      Route(.case(ServerRoute.api)) {
        Path {
          ServerRoute.Key.api.key
          "v1"
        }
        Parse(.memberwise(ServerRoute.Api.init(isDebug:route:))) {
          Headers {
            Field("X-DEBUG", default: false) { Bool.parser() }
          }
          ApiRouter(decoder: self.decoder, encoder: self.encoder)
        }
      }
    }
    //    .baseURL(baseURL)
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

public enum SiteRouterKey: DependencyKey {

  public static var testValue: AnyParserPrinter<URLRequestData, ServerRoute> {
    return SiteRouter(decoder: .init(), encoder: jsonEncoder)
      .eraseToAnyParserPrinter()
  }

  public static var liveValue: AnyParserPrinter<URLRequestData, ServerRoute> {
    return SiteRouter(decoder: .init(), encoder: jsonEncoder)
      .eraseToAnyParserPrinter()
  }
}

private enum BaseUrlKey: DependencyKey {

  static var testValue: String {
    "http://localhost:8080"
  }

  static var liveValue: String {
    "http://localhost:8080"
  }
}

extension DependencyValues {

  public var siteRouter: AnyParserPrinter<URLRequestData, ServerRoute> {
    get { self[SiteRouterKey.self].eraseToAnyParserPrinter() }
    set { self[SiteRouterKey.self] = .init(newValue) }
  }

  public var baseURL: String {
    get { self[BaseUrlKey.self] }
    set { self[BaseUrlKey.self] = newValue }
  }
}

private let jsonEncoder: JSONEncoder = {
  var encoder = JSONEncoder()
  encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
  return encoder
}()

// MARK: - Internal Typealias
typealias CoolingKey = ServerRoute.Documentation.Route.Interpolation.Cooling
typealias HeatingKey = ServerRoute.Documentation.Route.Interpolation.Heating
typealias InterpolationKey = ServerRoute.Documentation.Route.Interpolation.Key
typealias RouteKey = ServerRoute.Documentation.Route.Key
