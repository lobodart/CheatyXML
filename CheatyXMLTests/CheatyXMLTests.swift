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
        
        self.filePath = NSBundle(forClass: self.dynamicType).pathForResource("Test", ofType: "xml")
        XCTAssert(self.filePath != nil)
        
        self.failFilePath = NSBundle(forClass: self.dynamicType).pathForResource("TestFail", ofType: "xml")
        XCTAssert(self.failFilePath != nil)
        
        self.continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConstructor() {
        let failParser: XMLParser? = XMLParser(contentsOfURL: NSURL(fileURLWithPath: self.failFilePath))
        XCTAssert(failParser == nil)
        
        let url: NSURL = NSURL(fileURLWithPath: self.filePath)
        let urlParser: XMLParser! = XMLParser(contentsOfURL: url)
        XCTAssert(urlParser != nil)
        
        do {
            let content: String = try String(contentsOfFile: self.filePath)
            let stringParser: XMLParser! = XMLParser(string: content)
            XCTAssert(stringParser != nil)
            
            let data: NSData! = NSData(contentsOfURL: url)
            XCTAssert(data != nil)
            
            let dataParser: XMLParser! = XMLParser(data: data)
            XCTAssert(dataParser != nil)
        } catch {
            XCTAssert(false)
        }
    }
    
    func testTagRetrieving() {
        let url: NSURL = NSURL(fileURLWithPath: self.filePath)
        let parser: XMLParser = XMLParser(contentsOfURL: url)!
        
        let blogName: String! = parser["name"].stringValue
        XCTAssert(blogName == "MyAwesomeBlog!")
        
        let admin: String! = parser["users"]["admin"].stringValue
        XCTAssert(admin == "lobodart")
        
        let article: String! = parser["article"][0]["title"].stringValue
        XCTAssert(article == "My first article")
        
        let article2: String! = parser["article"][1]["title"].stringValue
        XCTAssert(article2 == "Another article")
        
        let articleOtherNotation: String! = parser["article", 0]["title"].stringValue
        XCTAssert(articleOtherNotation == "My first article")
        
        let article2OtherNotation: String! = parser["article", 1]["title"].stringValue
        XCTAssert(article2OtherNotation == "Another article")
    }
    
    func testTypeCasts() {
        let url: NSURL = NSURL(fileURLWithPath: self.filePath)
        let parser: XMLParser = XMLParser(contentsOfURL: url)!
        
        let articles = parser["article"].array
        XCTAssert(articles.count == 2)
        
        let article = articles[0]
        
        XCTAssert(article["title"].stringValue == "My first article")
        XCTAssert(article["read"].intValue == 324)
        XCTAssert(article["rate"].floatValue == 4.3)
        XCTAssert(article["rate"].doubleValue == 4.3)
        XCTAssert(article["date"].dateValue("yyyy-MM-dd HH:mm:ss").isKindOfClass(NSDate))
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
        let url: NSURL = NSURL(fileURLWithPath: self.filePath)
        let parser: XMLParser = XMLParser(contentsOfURL: url)!
        
        XCTAssert(parser.rootElement.attributes.count == 2)
        XCTAssert(parser.rootElement.attribute("version").stringValue == "1.0")
        XCTAssert(parser.rootElement.attribute("version").intValue == 1)
        XCTAssert(parser.rootElement.attribute("version").doubleValue == 1.0)
        XCTAssert(parser.rootElement.attribute("version").floatValue == 1.0)
        XCTAssert(parser.rootElement.attribute("creator").stringValue == "lobodart")
    }
}
