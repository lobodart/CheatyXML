//
//  XMLAttribute.swift
//  CheatyXML
//
//  Created by Louis BODART on 16/07/2016.
//  Copyright © 2016 Louis BODART. All rights reserved.
//

import Foundation

public class XMLAttribute: XMLElement {
    
    public let name: String!
    
    init(name: String!, value: String?) {
        self.name = name
        super.init(content: value)
    }
    
    public override var description: String {
        return "XMLAttribute"
    }
}