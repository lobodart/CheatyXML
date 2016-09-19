//
//  CXMLNullTag.swift
//  CheatyXML
//
//  Created by Louis BODART on 16/07/2016.
//  Copyright © 2016 Louis BODART. All rights reserved.
//

import Foundation

// MARK: - CXMLNullTag Class
open class CXMLNullTag: CXMLTag {
    
    open override var description: String {
        return "CXMLNullTag"
    }
    
    init() { super.init(tagName: nil) }
    
    open override subscript(tagName: String) -> CXMLTag! {
        get { return CXMLNullTag() }
    }
    
    open override subscript(index: Int) -> CXMLTag! {
        get { return CXMLNullTag() }
    }
    
    open override subscript(tagName: String, index: Int) -> CXMLTag! {
        get { return CXMLNullTag() }
    }
}
