//
//  PostObject.swift
//  CheatyXML
//
//  Created by Louis BODART on 26/10/2016.
//  Copyright © 2016 Louis BODART. All rights reserved.
//

import Foundation
import CheatyXML

class ArticleObject: NSObject, CXMLObjectProtocol {
    var title: String!
    var shortDescription: String!
    var read: NSNumber!
    
    public static func map() -> [String : String] {
        return [
            "title": "title",
            "description": "shortDescription",
            "read": "read"
        ]
    }
}
