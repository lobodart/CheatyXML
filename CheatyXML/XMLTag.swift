//
//  XMLTag.swift
//  CheatyXML
//
//  Created by Louis BODART on 16/07/2016.
//  Copyright © 2016 Louis BODART. All rights reserved.
//

import Foundation

// MARK: - XMLTag Class
public class XMLTag: XMLElement, SequenceType, GeneratorType {
    
    public let tagName: String!
    public var attributes: [XMLAttribute] {
        get {
            return self._attributes
        }
    }
    
    public var count: Int {
        get {
            guard let _ = self._parentElement else {
                return 1
            }
            
            let array: [XMLTag] = self._parentElement.arrayOfElementsNamed(self.tagName)
            return array.count
        }
    }
    
    public var numberOfChildElements: Int {
        get {
            return self._subElements.count
        }
    }
    
    internal var _subElements: [XMLTag] = []
    internal var _parentElement: XMLTag!
    internal var _attributes: [XMLAttribute] = []
    internal var _generatorIndex: Int = 0
    
    public override var debugDescription: String { get { return self.description } }
    public override var description: String {
        return "XMLTag <\(self.tagName)>, attributes(\(self.attributes.count ?? 0)): \(self.attributes), children: \(self._subElements.count)"
    }
    
    public var exists: Bool { get { return !(self is XMLNullTag) } }
    
    public var array: [XMLTag] { get { return self._parentElement?.arrayOfElementsNamed(self.tagName) ?? self._subElements } }
    
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
    
    public func generate() -> XMLTag {
        self._generatorIndex = 0
        return self
    }
    
    public func next() -> XMLTag? {
        if self._generatorIndex < 0 || self._generatorIndex >= self._subElements.count {
            return nil
        }
        
        let currentIndex: Int = self._generatorIndex
        self._generatorIndex += 1
        
        return self._subElements[currentIndex]
    }
    
    public func elementsNamed(name: String) -> [XMLTag] {
        return self.arrayOfElementsNamed(name)
    }
    
    public func attribute(name: String) -> XMLAttribute {
        guard let index = self._attributes.indexOf({ (attribute) -> Bool in
            return attribute.name == name
        }) else {
            return XMLNullAttribute()
        }
        
        return self._attributes[index]
    }
    
    private final func arrayOfElementsNamed(tagName: String) -> [XMLTag] {
        return self._subElements.filter({(element: XMLTag) -> Bool in
            return element.tagName == tagName
        })
    }
    
    internal final func addSubElement(subElement: XMLTag) {
        self._subElements.append(subElement)
    }
    
    init(tagName: String!) {
        self.tagName = tagName
        super.init(content: nil)
    }
    
    public subscript(tagName: String) -> XMLTag! {
        get {
            return self[tagName, 0]
        }
    }
    
    public subscript(index: Int) -> XMLTag! {
        get {
            return self._parentElement[self.tagName, index]
        }
    }
    
    public subscript(tagName: String, index: Int) -> XMLTag! {
        get {
            if index < 0 {
                return XMLNullTag()
            }
            
            let array = self._subElements.filter({(element: XMLTag) -> Bool in
                return element.tagName == tagName
            })
            
            if index >= array.count {
                return XMLNullTag()
            }
            
            return array[index]
        }
    }
}

public extension SequenceType where Generator.Element: XMLAttribute {
    
    public final var dictionary: [String: String] {
        get {
            return self.reduce([:], combine: { (dict: [String: String], value: XMLAttribute) -> [String: String] in
                var newDict = dict
                newDict[value.name] = value._content ?? ""
                return newDict
            })
        }
    }
}