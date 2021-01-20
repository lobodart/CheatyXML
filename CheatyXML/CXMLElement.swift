//
//  CXMLElement.swift
//  CheatyXML
//
//  Created by Louis BODART on 16/07/2016.
//  Copyright © 2016 Louis BODART. All rights reserved.
//

import Foundation

open class CXMLElement: NSObject {
    
    internal var _content: String?
    
    open var string: String? { get { return self._content } }
    open var stringValue: String { get { return self.string! } }
    open var int: Int? { get { return Int(self._content ?? "") ?? (self.double != nil ? Int(self.doubleValue) : nil) } }
    open var intValue: Int { get { return self.int! } }
    open var float: Float? { get { return Float(self._content ?? "") } }
    open var floatValue: Float { get { return self.float! } }
    open var double: Double? { get { return Double(self._content ?? "") } }
    open var doubleValue: Double { get { return self.double! } }
    
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
    
    internal init(content: String?) {
        self._content = content
        super.init()
    }
}
