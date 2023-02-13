import Dependencies
import Html
import PlaygroundSupport
import SiteRouter
import WebKit

@testable import DocumentMiddlewareLive

var greeting = "Hello, playground"

let current = layout(DocumentHome())

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 500, height: 700))
webView.loadHTMLString(render(current), baseURL: nil)

PlaygroundPage.current.liveView = webView
