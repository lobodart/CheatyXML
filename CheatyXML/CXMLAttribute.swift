//
//  CXMLAttribute.swift
//  CheatyXML
//
//  Created by Louis BODART on 16/07/2016.
//  Copyright © 2016 Louis BODART. All rights reserved.
//

import Foundation

open class CXMLAttribute: CXMLElement {
    
    public let name: String!
    
    init(name: String!, value: String?) {
        self.name = name
        super.init(content: value)
    }
    
    open override var description: String {
        return "CXMLAttribute"
    }
}
