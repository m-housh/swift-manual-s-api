import XCTest
import Html
import Stylesheet

final class StylesheetTests: XCTestCase {
  
  func test_align() {
    let sut = Class.align(.start)
    XCTAssertEqual(sut.description, "align-items-start")
  }
  
  func test_bg() {
    let sut = Class.bg(.success)
    XCTAssertEqual(sut.description, "bg-success")
  }
  
  func test_border() {
    let sut = Class.border
    XCTAssertEqual(sut.description, "border")
    
    let sut2 = Class.border(.warning)
    XCTAssertEqual(sut2.description, "border-warning")
  }
  
  func test_card() {
    var sut = Class.card
    XCTAssertEqual(sut.description, "card")
    
    sut = .card(.body)
    XCTAssertEqual(sut.description, "card-body")
    
    sut = .card(.subtitle)
    XCTAssertEqual(sut.description, "card-subtitle")
    
    sut = .card(.title)
    XCTAssertEqual(sut.description, "card-title")
  }
  
  func test_col() {
    let sut = Class.col
    XCTAssertEqual(sut.description, "col")
  }
  
  func test_container() {
    var sut = Class.container
    XCTAssertEqual(sut.description, "container")
    
    sut = .container(.fluid)
    XCTAssertEqual(sut.description, "container-fluid")
  }
  
  func test_fixedBottom() {
    let sut = Class.fixedBottom
    XCTAssertEqual(sut.description, "fixed-bottom")
  }
  
  func test_justify() {
    var sut = Class.justify(.start)
    XCTAssertEqual(sut.description, "justify-contents-start")
    
    sut = .justify(.end)
    XCTAssertEqual(sut.description, "justify-contents-end")
  }
  
  func test_margin() {
    var sut = Class.margin(.bottom(1))
    XCTAssertEqual(sut.description, "mb-1")
    
    sut = .margin(.end(2))
    XCTAssertEqual(sut.description, "me-2")
    
    sut = .margin(.start(3))
    XCTAssertEqual(sut.description, "ms-3")
    
    sut = .margin(.top(4))
    XCTAssertEqual(sut.description, "mt-4")
  }
  
  func test_nav() {
    var sut = Class.nav
    XCTAssertEqual(sut.description, "nav")
    
    sut = .nav(.item)
    XCTAssertEqual(sut.description, "nav-item")
    
    sut = .nav(.link)
    XCTAssertEqual(sut.description, "nav-link")
  }
  
  func test_navbar() {
    var sut = Class.navbar
    XCTAssertEqual(sut.description, "navbar")
    
    sut = .navbar(.brand)
    XCTAssertEqual(sut.description, "navbar-brand")
    
    sut = .navbar(.expandLarge)
    XCTAssertEqual(sut.description, "navbar-expand-lg")
    
    sut = .navbar(.nav)
    XCTAssertEqual(sut.description, "navbar-nav")
  }
  
  func test_padding() {
    var sut = Class.padding(.bottom(1))
    XCTAssertEqual(sut.description, "pb-1")
    
    sut = .padding(.end(2))
    XCTAssertEqual(sut.description, "pe-2")
    
    sut = .padding(.start(3))
    XCTAssertEqual(sut.description, "ps-3")
    
    sut = .padding(.top(4))
    XCTAssertEqual(sut.description, "pt-4")
  }
  
  func test_row() {
    let sut = Class.row
    XCTAssertEqual(sut.description, "row")
  }
  
  func test_text() {
    var sut = Class.text(.danger)
    XCTAssertEqual(sut.description, "text-danger")
    
    sut = .text(.primary, .emphasis)
    XCTAssertEqual(sut.description, "text-primary-emphasis")
  }
  
  func test_html() {
    let ul = Node.ul(
      attributes: [.class(.text(.light), .fixedBottom)],
        .li(.text("blob"))
    )
    let htmlString = render(ul)
    let expected = "<ul class=\"text-light fixed-bottom\"><li>blob</li></ul>"
    XCTAssertEqual(htmlString, expected)
    
  }
}
