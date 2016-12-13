//
//  LabelInset.swift
//  VideoTagger
//
//  Created by Martijn van Gogh on 12-12-16.
//  Copyright © 2016 Martijn van Gogh. All rights reserved.
//

import UIKit

class InsetLabel: UILabel {
    let topInset = CGFloat(0.0), bottomInset = CGFloat(0.0), leftInset = CGFloat(6), rightInset = CGFloat(0.0)
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
}
