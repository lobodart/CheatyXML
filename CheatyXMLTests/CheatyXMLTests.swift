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
    
    override func setUp() {
        super.setUp()
        
        self.filePath = NSBundle(forClass: self.dynamicType).pathForResource("Test", ofType: "xml")
        XCTAssert(self.filePath != nil, "Cannot open file Test.xml")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConstructor() {
        let url: NSURL = NSURL(fileURLWithPath: self.filePath)
        let urlParser: XMLParser! = XMLParser(contentsOfURL: url)
        XCTAssert(urlParser != nil, "XMLParser constructor with URL failed.")
        
        do {
            let content: String = try String(contentsOfFile: self.filePath)
            let stringParser: XMLParser! = XMLParser(string: content)
            XCTAssert(stringParser != nil, "XMLParser constructor with String failed.")
            
            let data: NSData! = NSData(contentsOfURL: url)
            XCTAssert(data != nil, "Cannot create NSData from file.")
            
            let dataParser: XMLParser! = XMLParser(data: data)
            XCTAssert(dataParser != nil, "XMLParser constructor with NSData failed.")
        } catch {
            XCTAssert(false, "Cannot open content of file.")
        }
    }
    
    func testTagRetrieving() {
        let url: NSURL = NSURL(fileURLWithPath: self.filePath)
        let parser: XMLParser = XMLParser(contentsOfURL: url)!
        
        let blogName: String! = parser["name"].stringValue
        XCTAssert(blogName == "MyAwesomeBlog!", "Cannot retrieve blogName.")
    }
}
