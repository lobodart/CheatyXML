//
//  CheatyXML.swift
//  CheatyXML
//
//  Created by Louis BODART on 14/03/2015.
//  Copyright (c) 2015 Louis BODART. All rights reserved.
//

import Foundation

// MARK: - XMLParser Class
public class XMLParser: NSObject, NSXMLParserDelegate {

    public var rootElement: XMLTag! {
        get {
            return self._rootElement
        }
    }
    
    private let _xmlParser: NSXMLParser!
    private var _pointerTree: [COpaquePointer]!
    private var _rootElement: XMLTag!
    private var _allocatedPointersList: [UnsafeMutablePointer<XMLTag>] = []
    
    public init?(contentsOfURL: NSURL) {
        self._xmlParser = NSXMLParser(contentsOfURL: contentsOfURL)
        
        super.init()
        if !self.initXMLParser() {
            return nil
        }
    }
    
    public init?(data: NSData!) {
        self._xmlParser = data != nil ? NSXMLParser(data: data) : nil
        
        super.init()
        guard let _ = self._xmlParser else {
            return nil
        }
        
        if !self.initXMLParser() {
            return nil
        }
    }
    
    public convenience init?(string: String) {
        self.init(data: NSString(string: string).dataUsingEncoding(NSUTF8StringEncoding))
    }
    
    deinit {
        for pointer in self._allocatedPointersList {
            pointer.dealloc(1)
        }
    }
    
    private func initXMLParser() -> Bool {
        guard let _ = self._xmlParser else {
            return false
        }
        
        self._xmlParser.delegate = self
        return self._xmlParser.parse()
    }
    
    public final func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        let newElement: XMLTag = XMLTag(tagName: elementName)
        if self._rootElement == nil {
            self._rootElement = newElement
        }
        
        if !attributeDict.isEmpty {
            newElement._attributes = attributeDict.map({ (name: String, value: String) -> XMLAttribute in
                return XMLAttribute(name: name, value: value)
            })
        }
        
        if self._pointerTree == nil {
            self._pointerTree = []
        } else {
            let nps = UnsafeMutablePointer<XMLTag>(self._pointerTree.last!)
            newElement._parentElement = nps.memory
            nps.memory.addSubElement(newElement)
        }
        
        let ps = UnsafeMutablePointer<XMLTag>.alloc(1)
        ps.initialize(newElement)
        self._allocatedPointersList.append(ps)
        let cps = COpaquePointer(ps)
        self._pointerTree.append(cps)
    }
    
    public final func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        self._pointerTree.removeLast()
    }
    
    public final func parser(parser: NSXMLParser, foundCharacters string: String) {
        let nps = UnsafeMutablePointer<XMLTag>(self._pointerTree.last!)
        var tmpString: String! = nps.memory._content ?? ""
        tmpString! += string
        
        let regex: NSRegularExpression = try! NSRegularExpression(pattern: "[^\\n\\s]+", options: [])
        if regex.matchesInString(tmpString, options: [], range: NSMakeRange(0, tmpString.characters.count)).count <= 0 {
            tmpString = nil
        }
        
        nps.memory._content = tmpString
    }
    
    public subscript(tagName: String) -> XMLTag! {
        return self._rootElement[tagName]
    }
    
    public subscript(tagName: String, index: Int) -> XMLTag! {
        return self._rootElement[tagName, index]
    }
}