//
//  XMLNullAttribute.swift
//  CheatyXML
//
//  Created by Louis BODART on 17/07/2016.
//  Copyright © 2016 Louis BODART. All rights reserved.
//

import Foundation

// MARK: - XMLNullAttribute Class
public class XMLNullAttribute: XMLAttribute {
    
    public override var description: String {
        return "XMLNullAttribute"
    }
    
    init() { super.init(name: nil, value: nil) }
}