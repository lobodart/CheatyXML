//
//  XMLElement.swift
//  CheatyXML
//
//  Created by Louis BODART on 16/07/2016.
//  Copyright © 2016 Louis BODART. All rights reserved.
//

import Foundation

public class XMLElement: NSObject {
    
    internal var _content: String?
    
    public var string: String? { get { return self._content } }
    public var stringValue: String { get { return self.string! } }
    public var int: Int? { get { return Int(self._content ?? "") ?? (self.double != nil ? Int(self.doubleValue) : nil) } }
    public var intValue: Int { get { return self.int! } }
    public var float: Float? { get { return Float(self._content ?? "") } }
    public var floatValue: Float { get { return self.float! } }
    public var double: Double? { get { return Double(self._content ?? "") } }
    public var doubleValue: Double { get { return self.double! } }
    
    internal init(content: String?) {
        self._content = content
        super.init()
    }
}