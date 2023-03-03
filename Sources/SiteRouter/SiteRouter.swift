import Dependencies
import Foundation
import Models
@_exported import URLRouting

public struct SiteRouter: ParserPrinter {

  public init() {}

  @ParserBuilder
  public var body: AnyParserPrinter<URLRequestData, ServerRoute> {
    OneOf {
      Route(.case(ServerRoute.home))

      Route(.case(ServerRoute.favicon)) {
        Path { "favicon.ico" }
      }

      Route(.case(ServerRoute.appleTouchIcon)) {
        Path { "apple-touch-icon.png" }
      }

      Route(.case(ServerRoute.appleTouchIcon)) {
        Path { "apple-touch-icon-precomposed.png" }
      }

      Route(.case(ServerRoute.siteManifest)) {
        Path { "site.webmanifest" }
      }

      Route(.case(ServerRoute.documentation)) {
        Path { ServerRoute.Key.documentation.key }
        DocumentRouter()
      }

      Route(.case(ServerRoute.public)) {
        Path { "public" }
        OneOf {
          Route(.case(ServerRoute.Public.favicon)) {
            Path { "favicon.png" }
          }

          Route(.case(ServerRoute.Public.images(file:))) {
            Path { "images" }
            Query {
              Field("file")
            }
          }

          Route(.case(ServerRoute.Public.tools(file:))) {
            Path { "tools" }
            Query {
              Field("file")
            }
          }
        }
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
          ApiRouter()
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

public enum SiteRouterKey: DependencyKey {

  public static var testValue: AnyParserPrinter<URLRequestData, ServerRoute> {
    return Self.liveValue
  }

  public static var liveValue: AnyParserPrinter<URLRequestData, ServerRoute> {
    return SiteRouter().eraseToAnyParserPrinter()
  }
}

extension DependencyValues {

  public var siteRouter: AnyParserPrinter<URLRequestData, ServerRoute> {
    get { self[SiteRouterKey.self].eraseToAnyParserPrinter() }
    set { self[SiteRouterKey.self] = .init(newValue) }
  }
}

// MARK: - Internal Typealias
typealias CoolingKey = ServerRoute.Documentation.Route.Interpolation.Cooling
typealias HeatingKey = ServerRoute.Documentation.Route.Interpolation.Heating
typealias InterpolationKey = ServerRoute.Documentation.Route.Interpolation.Key
typealias RouteKey = ServerRoute.Documentation.Route.Key
