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

}
