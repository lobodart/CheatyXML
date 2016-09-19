//
//  CXMLNullAttribute.swift
//  CheatyXML
//
//  Created by Louis BODART on 17/07/2016.
//  Copyright © 2016 Louis BODART. All rights reserved.
//

import Foundation

// MARK: - CXMLNullAttribute Class
open class CXMLNullAttribute: CXMLAttribute {
    
    open override var description: String {
        return "CXMLNullAttribute"
    }
    
    init() { super.init(name: nil, value: nil) }
}
