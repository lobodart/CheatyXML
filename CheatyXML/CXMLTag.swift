//
//  CXMLTag.swift
//  CheatyXML
//
//  Created by Louis BODART on 16/07/2016.
//  Copyright © 2016 Louis BODART. All rights reserved.
//

import Foundation

// MARK: - CXMLTag Class
open class CXMLTag: CXMLElement, Sequence, IteratorProtocol {
    
    open let tagName: String!
    open var attributes: [CXMLAttribute] {
        get {
            return self._attributes
        }
    }
    
    open var count: Int {
        get {
            guard let _ = self._parentElement else {
                return 1
            }
            
            let array: [CXMLTag] = self._parentElement.arrayOfElementsNamed(self.tagName)
            return array.count
        }
    }
    
    open var numberOfChildElements: Int {
        get {
            return self._subElements.count
        }
    }
    
    internal var _subElements: [CXMLTag] = []
    internal var _parentElement: CXMLTag!
    internal var _attributes: [CXMLAttribute] = []
    internal var _generatorIndex: Int = 0
    
    open override var debugDescription: String { get { return self.description } }
    open override var description: String {
        return "CXMLTag <\(self.tagName)>, attributes(\(self.attributes.count)): \(self.attributes), children: \(self._subElements.count)"
    }
    
    open var exists: Bool { get { return !(self is CXMLNullTag) } }
    
    open var array: [CXMLTag] { get { return self._parentElement?.arrayOfElementsNamed(self.tagName) ?? self._subElements } }
    
    open func date(_ format: String) -> Date? {
        guard let content = self._content else {
            return nil
        }
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.date(from: content)
    }
    
    open func dateValue(_ format: String) -> Date {
        return self.date(format)!
    }
    
    open func makeIterator() -> CXMLTag {
        self._generatorIndex = 0
        return self
    }
    
    open func next() -> CXMLTag? {
        if self._generatorIndex < 0 || self._generatorIndex >= self._subElements.count {
            return nil
        }
        
        defer { self._generatorIndex += 1 }
        
        return self._subElements[self._generatorIndex]
    }
    
    open func elementsNamed(_ name: String) -> [CXMLTag] {
        return self.arrayOfElementsNamed(name)
    }
    
    open func attribute(_ name: String) -> CXMLAttribute {
        guard let index = self._attributes.index(where: { (attribute) -> Bool in
            return attribute.name == name
        }) else {
            return CXMLNullAttribute()
        }
        
        return self._attributes[index]
    }
    
    open func toObject<T: NSObject>() -> T where T: CXMLObjectProtocol {
        let object: T = T()
        for (xmlValue, classValue) in T.map() {
            guard let value = self[xmlValue] else {
                continue
            }
            
            let castedValue: Any?
            if let v = value.double {
                castedValue = v
            } else if let v = value.int {
                castedValue = v
            } else if let v = value.string {
                castedValue = v
            } else {
                continue
            }
            
            object.setValue(castedValue, forKey: classValue)
        }
        
        return object
    }
    
    fileprivate final func arrayOfElementsNamed(_ tagName: String) -> [CXMLTag] {
        return self._subElements.filter({(element: CXMLTag) -> Bool in
            return element.tagName == tagName
        })
    }
    
    internal final func addSubElement(_ subElement: CXMLTag) {
        self._subElements.append(subElement)
    }
    
    init(tagName: String!) {
        self.tagName = tagName
        super.init(content: nil)
    }
    
    open subscript(tagName: String) -> CXMLTag! {
        get {
            return self[tagName, 0]
        }
    }
    
    open subscript(index: Int) -> CXMLTag! {
        get {
            return self._parentElement[self.tagName, index]
        }
    }
    
    open subscript(tagName: String, index: Int) -> CXMLTag! {
        get {
            if index < 0 {
                return CXMLNullTag()
            }
            
            let array = self._subElements.filter({(element: CXMLTag) -> Bool in
                return element.tagName == tagName
            })
            
            if index >= array.count {
                return CXMLNullTag()
            }
            
            return array[index]
        }
    }
}

public extension Sequence where Iterator.Element: CXMLAttribute {
    
    public final var dictionary: [String: String] {
        get {
            return self.reduce([:], { (dict: [String: String], value: CXMLAttribute) -> [String: String] in
                var newDict = dict
                newDict[value.name] = value._content ?? ""
                return newDict
            })
        }
    }
}
