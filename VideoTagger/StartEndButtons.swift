//
//  StartEndButtons.swift
//  VideoTagger
//
//  Created by Martijn van Gogh on 06-12-16.
//  Copyright © 2016 Martijn van Gogh. All rights reserved.
//

import UIKit

class StartEndButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpButtons()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpButtons()
    }

    
    override func awakeFromNib() {
        setUpButtons()
    }
    
    func setUpButtons() {
        self.layer.cornerRadius = 22.5
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        self.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.backgroundColor = UIColor.red
        self.setTitle("Add start", for: .normal)
        self.titleLabel?.textAlignment = .center
        self.setTitleColor(.white, for: .normal)
    }
}

