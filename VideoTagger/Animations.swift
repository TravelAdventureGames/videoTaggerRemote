//
//  Animations.swift
//  VideoTagger
//
//  Created by Martijn van Gogh on 30-12-16.
//  Copyright © 2016 Martijn van Gogh. All rights reserved.
//

import UIKit

extension UIButton {

    func wobblingButton() {
        let animation = CAKeyframeAnimation(keyPath: "position.x")
        animation.values = [0, 0, 0, 0, -2, 2, -2, 0, 0, 0, 0]
        animation.keyTimes = [0, 0.09, 0.18, 0.27, 0.36, 0.39, 0.42, 0.45, 0.72, 0.81, 0.90, 1]
        animation.isAdditive = true
        animation.duration = 2
        animation.repeatCount = Float.infinity
        self.layer.add(animation, forKey: "shake")
    }
}
