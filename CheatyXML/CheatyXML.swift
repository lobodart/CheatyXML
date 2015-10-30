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

        public let tagName: String?
        public let attributes: [String: String]

        public var count: Int {
            get {
                guard let element = self._parentElement, tagName = self.tagName else {
                    return 1
                }

                return element.arrayOfElementsNamed(tagName).count
            }
        }

        public var numberOfChildElements: Int {
            get {
                return self._subElements?.count ?? 0
            }
        }

        private var _subElements: [XMLElement]?
        private var _content: String?
        private var _parentElement: XMLElement?
        private var _generatorIndex: Int = 0

        public override var debugDescription: String { get { return self.description } }

        public var stringValue: String! {
            get { return self._content! }
        }

        public var string: String? {
            get { return self._content }
        }

        init(tagName: String?, attributes: [String: String]) {
            self.tagName = tagName
            self.attributes = attributes
        }

        public override var description: String {
            return "XMLElement <\(self.tagName)>, attributes(\(self.attributes.count ?? 0)): \(self.attributes), children: \(self._subElements?.count ?? 0)"
        }

        public func generate() -> XMLElement {
            self._generatorIndex = 0
            return self
        }

        public func next() -> XMLElement? {
            if self._generatorIndex < 0 || self._generatorIndex >= self._subElements?.count {
                return nil
            }

            return self._subElements?[self._generatorIndex++]
        }

        public func elementsNamed(name: String) -> [XMLElement] {
            return self.arrayOfElementsNamed(name)
        }

        private final func arrayOfElementsNamed(tagName: String) -> [XMLElement] {
            return self._subElements?.filter({(element: XMLElement) -> Bool in
                return element.tagName == tagName
            }) ?? Array()
        }

        private final func addSubElement(subElement: XMLElement) {
            if self._subElements == nil {
                self._subElements = []
            }

            self._subElements?.append(subElement)
        }

        public subscript(tagName: String) -> XMLElement {
            get {
                return self[tagName, 0]
            }
        }

        public subscript(index: Int) -> XMLElement {
            get {
				if let parentElement = self._parentElement, tagName = self.tagName {
					return parentElement[tagName, index]
				} else {
					return XMLNullElement()
				}
            }
        }

        public subscript(tagName: String, index: Int) -> XMLElement {
            get {
                if index < 0 {
                    return XMLNullElement()
                }

                let array = self._subElements?.filter({(element: XMLElement) -> Bool in
                    return element.tagName == tagName
                }) ?? Array()

                if index >= array.count {
                    return XMLNullElement()
                }

                return array[index]
            }
        }
    }

    public class XMLNullElement: XMLElement {

        init() { super.init(tagName: nil, attributes: Dictionary()) }

        public override var description: String {
            return "XMLNullElement"
        }

        public override subscript(tagName: String) -> XMLElement {
            get { return XMLNullElement() }
        }

        public override subscript(index: Int) -> XMLElement {
            get { return XMLNullElement() }
        }

        public override subscript(tagName: String, index: Int) -> XMLElement {
            get { return XMLNullElement() }
        }
    }

    public private(set) var rootElement: XMLElement?
    private let _xmlParser: NSXMLParser
    private var _pointerTree: [COpaquePointer]!
	private let _regex: NSRegularExpression = try! NSRegularExpression(pattern: "[^\\n\\s]+", options: [])

    public convenience init?(contentsOfURL: NSURL) {
        guard let xmlParser = NSXMLParser(contentsOfURL: contentsOfURL) else {
            return nil
        }

        self.init(xmlParser: xmlParser)
    }

    public convenience init?(data: NSData?) {
        guard let data = data else {
            return nil
        }

        self.init(xmlParser: NSXMLParser(data: data))
    }

    public convenience init?(string: String) {
        self.init(data: NSString(string: string).dataUsingEncoding(NSUTF8StringEncoding))
    }

    private init?(xmlParser: NSXMLParser) {
        self._xmlParser = xmlParser
        super.init()

        self._xmlParser.delegate = self

        if self._xmlParser.parse() == false {
            return nil
        }
    }

    public final func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        let newElement: XMLElement = XMLElement(tagName: elementName, attributes: attributeDict)
        if self.rootElement == nil {
            self.rootElement = newElement
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
        var tmpString = nps.memory._content ?? ""
        tmpString += string

        if self._regex.matchesInString(tmpString, options: [], range: NSMakeRange(0, tmpString.characters.count)).count > 0 {
            nps.memory._content = tmpString
        } else {
            nps.memory._content = nil
        }
    }

    public subscript(tagName: String) -> XMLElement {
        return self.rootElement?[tagName] ?? XMLNullElement()
    }

    public subscript(tagName: String, index: Int) -> XMLElement {
		return self.rootElement?[tagName, index] ?? XMLNullElement()
    }

}
