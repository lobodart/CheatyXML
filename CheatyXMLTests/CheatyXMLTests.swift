//
//  CheatyXMLTests.swift
//  CheatyXMLTests
//
//  Created by Louis BODART on 14/03/2015.
//  Copyright (c) 2015 Louis BODART. All rights reserved.
//

import UIKit
import XCTest
import CheatyXML

class CheatyXMLTests: XCTestCase {
    
    var filePath: String!
    var failFilePath: String!
    
    override func setUp() {
        super.setUp()
        
        self.filePath = Bundle(for: type(of: self)).path(forResource: "Test", ofType: "xml")
        XCTAssert(self.filePath != nil)
        
        self.failFilePath = Bundle(for: type(of: self)).path(forResource: "TestFail", ofType: "xml")
        XCTAssert(self.failFilePath != nil)
        
        self.continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConstructor() {
        let failParser: CXMLParser? = CXMLParser(contentsOfURL: URL(fileURLWithPath: self.failFilePath))
        XCTAssert(failParser == nil)
        
        let url: URL = URL(fileURLWithPath: self.filePath)
        let urlParser: CXMLParser! = CXMLParser(contentsOfURL: url)
        XCTAssert(urlParser != nil)
        
        do {
            let content: String = try String(contentsOfFile: self.filePath)
            let stringParser: CXMLParser! = CXMLParser(string: content)
            XCTAssert(stringParser != nil)
            
            let data: Data! = try? Data(contentsOf: url)
            XCTAssert(data != nil)
            
            let dataParser: CheatyXML.XMLParser! = CheatyXML.XMLParser(data: data)
            XCTAssert(dataParser != nil)
        } catch {
            XCTAssert(false)
        }
    }
    
    func testTagRetrieving() {
        let url: URL = URL(fileURLWithPath: self.filePath)
        let parser: CXMLParser = CXMLParser(contentsOfURL: url)!
        
        XCTAssert(parser["name"].stringValue == "MyAwesomeBlog!")
        XCTAssert(parser["namee"] is CXMLNullTag)
        XCTAssert(parser["namee"].description == "CXMLNullTag")
        
        XCTAssert(parser["users"]["admin"].stringValue == "lobodart")
        
        XCTAssert(parser["article"][0]["title"].stringValue == "My first article")
        XCTAssert(parser["article"][1]["title"].stringValue == "Another article")
        XCTAssert(parser["article"][2] is CXMLNullTag)
        
        XCTAssert(parser["article", 0]["title"].stringValue == "My first article")
        XCTAssert(parser["article", 1]["title"].stringValue == "Another article")
        XCTAssert(parser["article", 2] is CXMLNullTag)
        
        for article in parser.rootElement.elementsNamed("article") {
            XCTAssert(article["title"].string != nil)
        }
        
        XCTAssert(parser.rootElement.count == 1)
        XCTAssert(parser["article"].count == 2)
        XCTAssert(parser["article"].numberOfChildElements == 7)
    }
    
    func testTypeCasts() {
        let url: URL = URL(fileURLWithPath: self.filePath)
        let parser: CXMLParser = CXMLParser(contentsOfURL: url)!
        
        let articles = parser["article"].array
        XCTAssert(articles.count == 2)
        XCTAssert(articles == parser.rootElement.elementsNamed("article"))
        
        let article = articles[0]
        
        XCTAssert(article["title"].stringValue == "My first article")
        XCTAssert(article["read"].intValue == 324)
        XCTAssert(article["rate"].floatValue == 4.3)
        XCTAssert(article["rate"].doubleValue == 4.3)
        XCTAssert(article["date"].dateValue("yyyy-MM-dd HH:mm:ss") is Date)
        XCTAssert(article["title"].exists == true)
        
        XCTAssert(article["foo"].string == nil)
        XCTAssert(article["bar"].int == nil)
        XCTAssert(article["john"].float == nil)
        XCTAssert(article["doe"].double == nil)
        XCTAssert(article["date"].date("failFormat") == nil)
        XCTAssert(article["failDate"].date("yyyy-MM-dd HH:mm:ss") == nil)
        XCTAssert(article["42"].exists == false)
    }
    
    func testAttributeRetrieving() {
        let url: URL = URL(fileURLWithPath: self.filePath)
        let parser: CXMLParser = CXMLParser(contentsOfURL: url)!
        
        XCTAssert(parser.rootElement.attributes.count == 2)
        XCTAssert(parser.rootElement.attribute("version").stringValue == "1.0")
        XCTAssert(parser.rootElement.attribute("version").intValue == 1)
        XCTAssert(parser.rootElement.attribute("version").doubleValue == 1.0)
        XCTAssert(parser.rootElement.attribute("version").floatValue == 1.0)
        XCTAssert(parser.rootElement.attribute("creator").stringValue == "lobodart")
        XCTAssert(parser.rootElement.attribute("creator").description == "CXMLAttribute")
        XCTAssert(parser.rootElement.attribute("creatorr") is CXMLNullAttribute)
        XCTAssert(parser.rootElement.attribute("creatorr").description == "CXMLNullAttribute")
        
        let firstArticle: CXMLTag = parser["article"].array[0]
        XCTAssert(firstArticle.attribute("date").date("yyyy-MM-dd HH:mm:ss") != nil)
        XCTAssert(firstArticle.attribute("date").date("yyyy-MM-dd") == nil) // invalid format
        XCTAssert(firstArticle.attribute("failDate").date("yyyy-MM-dd HH:mm:ss") == nil)
        XCTAssert(firstArticle.attribute("date").dateValue("yyyy-MM-dd HH:mm:ss") is Date)
    }
}
