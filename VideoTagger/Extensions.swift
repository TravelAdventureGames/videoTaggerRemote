//
//  Extensions.swift
//  VideoTagger
//
//  Created by Martijn van Gogh on 30-12-16.
//  Copyright © 2016 Martijn van Gogh. All rights reserved.
//

import UIKit

extension Double {
    func secondsToHoursMinutesSeconds () -> (Int, Int, Int) {
        let (hr,  minf) = modf (self / 3600)
        let (min, secf) = modf (60 * minf)
        return (Int(hr), Int(min), 60 * Int(secf))
    }
}
