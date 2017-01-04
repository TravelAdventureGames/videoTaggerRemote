//
//  Extensions.swift
//  VideoTagger
//
//  Created by Martijn van Gogh on 30-12-16.
//  Copyright © 2016 Martijn van Gogh. All rights reserved.
//

import UIKit

extension Int {
//    func secondsToHoursMinutesSeconds () -> (Double, Double, Double) {
//        let (hr,  minf) = modf (self / 3600)
//        let (min, secf) = modf (60 * minf)
//        return (hr, min, 60 * secf)
//    }
    
    func secondsToHoursMinutesSeconds () -> (String, String, String) {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 2
        let (hr, min, sec) = (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
        let hrs = String(format: "%02d", hr)
        let mins = String(format: "%02d", min)
        let secs = String(format: "%02d", sec)
        return (hrs, mins, secs)
    }
}
