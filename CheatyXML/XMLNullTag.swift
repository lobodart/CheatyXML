//
//  XMLNullTag.swift
//  CheatyXML
//
//  Created by Louis BODART on 16/07/2016.
//  Copyright © 2016 Louis BODART. All rights reserved.
//

import Foundation

// MARK: - XMLNullTag Class
public class XMLNullTag: XMLTag {
    
    public override var description: String {
        return "XMLNullTag"
    }
    
    init() { super.init(tagName: nil) }
    
    public override subscript(tagName: String) -> XMLTag! {
        get { return XMLNullTag() }
    }
    
    public override subscript(index: Int) -> XMLTag! {
        get { return XMLNullTag() }
    }
    
    public override subscript(tagName: String, index: Int) -> XMLTag! {
        get { return XMLNullTag() }
    }
}