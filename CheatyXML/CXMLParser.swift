//
//  CXMLParser.swift
//  CheatyXML
//
//  Created by Louis BODART on 14/03/2015.
//  Copyright (c) 2015 Louis BODART. All rights reserved.
//

import Foundation

// MARK: - CXMLParser Class
public class CXMLParser: NSObject, XMLParserDelegate {

    open var rootElement: CXMLTag! {
        get {
            return self._rootElement
        }
    }
    
    fileprivate let _xmlParser: Foundation.XMLParser!
    fileprivate var _pointerTree: [OpaquePointer]!
    fileprivate var _rootElement: CXMLTag!
    fileprivate var _allocatedPointersList: [UnsafeMutablePointer<CXMLTag>] = []
    
    public init?(contentsOfURL: URL) {
        self._xmlParser = Foundation.XMLParser(contentsOf: contentsOfURL)
        
        super.init()
        if !self.initXMLParser() {
            return nil
        }
    }
    
    public init?(data: Data?) {
        guard let data = data else {
            return nil
        }
        
        self._xmlParser = Foundation.XMLParser(data: data)
        
        super.init()
        guard let _ = self._xmlParser else {
            return nil
        }
        
        if !self.initXMLParser() {
            return nil
        }
    }
    
    public convenience init?(string: String) {
        self.init(data: string.data(using: String.Encoding.utf8))
    }
    
    deinit {
        for pointer in self._allocatedPointersList {
            pointer.deallocate()
        }
    }
    
    fileprivate func initXMLParser() -> Bool {
        guard let _ = self._xmlParser else {
            return false
        }
        
        self._xmlParser.delegate = self
        return self._xmlParser.parse()
    }
    
    public final func parser(_ parser: Foundation.XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        let newElement: CXMLTag = CXMLTag(tagName: elementName)
        if self._rootElement == nil {
            self._rootElement = newElement
        }
        
        if !attributeDict.isEmpty {
            newElement._attributes = attributeDict.map({ (name: String, value: String) -> CXMLAttribute in
                return CXMLAttribute(name: name, value: value)
            })
        }
        
        if self._pointerTree == nil {
            self._pointerTree = []
        } else {
            let nps = UnsafeMutablePointer<CXMLTag>(self._pointerTree.last!)
            newElement._parentElement = nps.pointee
            nps.pointee.addSubElement(newElement)
        }
        
        let ps = UnsafeMutablePointer<CXMLTag>.allocate(capacity: 1)
        ps.initialize(to: newElement)
        self._allocatedPointersList.append(ps)
        let cps = OpaquePointer(ps)
        self._pointerTree.append(cps)
    }
    
    public final func parser(_ parser: Foundation.XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        self._pointerTree.removeLast()
    }
    
    public final func parser(_ parser: Foundation.XMLParser, foundCharacters string: String) {
        let nps = UnsafeMutablePointer<CXMLTag>(self._pointerTree.last!)
        var tmpString: String! = nps.pointee._content ?? ""
        tmpString! += string
        
        let regex: NSRegularExpression = try! NSRegularExpression(pattern: "[^\\n\\s]+", options: [])
        if regex.matches(in: tmpString, options: [], range: NSMakeRange(0, tmpString.count)).count <= 0 {
            tmpString = nil
        }
        
        nps.pointee._content = tmpString
    }
    
    open subscript(tagName: String) -> CXMLTag! {
        return self._rootElement[tagName]
    }
    
    open subscript(tagName: String, index: Int) -> CXMLTag! {
        return self._rootElement[tagName, index]
    }
}
