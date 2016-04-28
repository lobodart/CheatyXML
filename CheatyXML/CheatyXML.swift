//
//  CheatyXML.swift
//  CheatyXML
//
//  Created by Louis BODART on 14/03/2015.
//  Copyright (c) 2015 Louis BODART. All rights reserved.
//

import Foundation

public class XMLParser: NSObject, NSXMLParserDelegate {
    
    public class XMLElement: NSObject, SequenceType, GeneratorType {
        
        public let tagName: String!
        public var attributes: [NSObject: AnyObject] {
            get {
                return self._attributes
            }
        }
        
        public var count: Int {
            get {
                guard let _ = self._parentElement else {
                    return 1
                }
                
                let array: [XMLElement] = self._parentElement.arrayOfElementsNamed(self.tagName)
                return array.count
            }
        }
        
        public var numberOfChildElements: Int {
            get {
                return self._subElements.count
            }
        }
        
        private var _subElements: [XMLElement] = []
        private var _content: String?
        private var _parentElement: XMLElement!
        private var _attributes: [NSObject: AnyObject] = [:]
        private var _generatorIndex: Int = 0
        
        //override public var debugDescription: String { get { return self.description() } }
        
        private var _numberContent: NSNumber? {
            get {
                guard let content = self._content else {
                    return nil
                }
                
                let formatter: NSNumberFormatter = NSNumberFormatter()
                formatter.numberStyle = .DecimalStyle
                return formatter.numberFromString(content)
            }
        }
        
        public var exists: Bool { get { return !(self is XMLNullElement) } }
        
        public var string: String? { get { return self._content } }
        public var stringValue: String { get { return self.string! } }
        public var int: Int? { get { return self._numberContent?.integerValue } }
        public var intValue: Int { get { return self.int! } }
        public var float: Float? { get { return self._numberContent?.floatValue } }
        public var floatValue: Float { get { return self.float! } }
        public var double: Double? { get { return self._numberContent?.doubleValue } }
        public var doubleValue: Double { get { return self.double! } }
        public var number: NSNumber? { get { return self._numberContent } }
        public var numberValue: NSNumber { get { return self.number! } }
        public var array: [XMLElement] { get { return self._parentElement?.arrayOfElementsNamed(self.tagName) ?? self._subElements } }
        
        public func date(format: String) -> NSDate? {
            guard let content = self._content else {
                return nil
            }
            
            let dateFormat = NSDateFormatter()
            dateFormat.dateFormat = format
            return dateFormat.dateFromString(content)
        }
        
        public func dateValue(format: String) -> NSDate {
            return self.date(format)!
        }
        
        init(tagName: String!) {
            self.tagName = tagName
        }
        
        // Problem with Swift 1.2
        /*public func description() -> String {
            return "XMLElement <\(self.tagName)>, attributes(\(self.attributes?.count ?? 0)): \(self.attributes), children: \(self._subElements?.count ?? 0)"
        }*/
        
        public func generate() -> XMLElement {
            self._generatorIndex = 0
            return self
        }
        
        public func next() -> XMLElement? {
            if self._generatorIndex < 0 || self._generatorIndex >= self._subElements.count {
                return nil
            }
            
            return self._subElements[self._generatorIndex++]
        }
        
        public func elementsNamed(name: String) -> [XMLElement] {
            return self.arrayOfElementsNamed(name)
        }
        
        private final func arrayOfElementsNamed(tagName: String) -> [XMLElement] {
            return self._subElements.filter({(element: XMLElement) -> Bool in
                return element.tagName == tagName
            })
        }
        
        private final func addSubElement(subElement: XMLElement) {
            self._subElements.append(subElement)
        }
        
        public subscript(tagName: String) -> XMLElement! {
            get {
                return self[tagName, 0]
            }
        }
        
        public subscript(index: Int) -> XMLElement! {
            get {
                return self._parentElement[self.tagName, index]
            }
        }
        
        public subscript(tagName: String, index: Int) -> XMLElement! {
            get {
                if index < 0 {
                    return XMLNullElement()
                }
                
                let array = self._subElements.filter({(element: XMLElement) -> Bool in
                    return element.tagName == tagName
                })
                
                if index >= array.count {
                    return XMLNullElement()
                }
                
                return array[index]
            }
        }
    }
    
    public class XMLNullElement: XMLElement {
        
        init() { super.init(tagName: nil) }
        
        // Problem with Swift 1.2
        /*public override func description() -> String {
            return "XMLNullElement"
        }*/
        
        public override subscript(tagName: String) -> XMLElement! {
            get { return XMLNullElement() }
        }
        
        public override subscript(index: Int) -> XMLElement! {
            get { return XMLNullElement() }
        }
        
        public override subscript(tagName: String, index: Int) -> XMLElement! {
            get { return XMLNullElement() }
        }
    }
    
    public var rootElement: XMLElement! {
        get {
            return self._rootElement
        }
    }
    
    private let _xmlParser: NSXMLParser!
    private var _pointerTree: [COpaquePointer]!
    private var _rootElement: XMLElement!
    
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
        if self._xmlParser == nil {
            return nil
        }
        
        if !self.initXMLParser() {
            return nil
        }
    }
    
    public convenience init?(string: String) {
        self.init(data: NSString(string: string).dataUsingEncoding(NSUTF8StringEncoding))
    }
    
    private func initXMLParser() -> Bool {
        guard let _ = self._xmlParser else {
            return false
        }
        
        self._xmlParser.delegate = self
        return self._xmlParser.parse()
    }
    
    public final func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        let newElement: XMLElement = XMLElement(tagName: elementName)
        if self._rootElement == nil {
            self._rootElement = newElement
        }
        
        if !attributeDict.isEmpty {
            newElement._attributes = attributeDict
        }
        
        if self._pointerTree == nil {
            self._pointerTree = []
        } else {
            let nps = UnsafeMutablePointer<XMLElement>(self._pointerTree.last!)
            newElement._parentElement = nps.memory
            nps.memory.addSubElement(newElement)
        }
    
        let ps = UnsafeMutablePointer<XMLElement>.alloc(1)
        ps.initialize(newElement)
        let cps = COpaquePointer(ps)
        self._pointerTree.append(cps)
    }
    
    public final func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        self._pointerTree.removeLast()
    }
    
    public final func parser(parser: NSXMLParser, foundCharacters string: String) {
        let nps = UnsafeMutablePointer<XMLElement>(self._pointerTree.last!)
        var tmpString: String! = nps.memory._content ?? ""
        tmpString! += string
        
        let regex: NSRegularExpression = try! NSRegularExpression(pattern: "[^\\n\\s]+", options: [])
        if regex.matchesInString(tmpString, options: [], range: NSMakeRange(0, tmpString.characters.count)).count <= 0 {
            tmpString = nil
        }
        
        nps.memory._content = tmpString
    }
    
    public subscript(tagName: String) -> XMLElement! {
        return self._rootElement[tagName]
    }
    
    public subscript(tagName: String, index: Int) -> XMLElement! {
        return self._rootElement[tagName, index]
    }
}