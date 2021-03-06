//
//  Tagpoints.swift
//  VideoTagger
//
//  Created by Martijn van Gogh on 05-12-16.
//  Copyright © 2016 Martijn van Gogh. All rights reserved.
//

import UIKit

enum Prioriteit {
    case Laag, Midden, Hoog
}

class Tagpoint: NSObject {
    
    var beginTime: Double?
    var endTime: Double?
    var title: String?
    var comment: String?
    var begMult: Double?
    var endMult: Double?
    
    init?(representation: AnyObject) {
        if let data = (representation as! NSDictionary).value(forKey: "subscription") as? [String: AnyObject] {
            title = data["title"] as? String
            comment = data["comment"] as? String
            beginTime = data["beginTime"] as? Double
            endTime = data["endTime"] as? Double
            begMult = data["begMult"] as? Double
            endMult = data["endMult"] as? Double
    
        }
    }
}

