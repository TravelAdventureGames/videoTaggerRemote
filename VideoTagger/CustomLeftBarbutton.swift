//
//  CustomLeftBarbutton.swift
//  VideoTagger
//
//  Created by Martijn van Gogh on 12-12-16.
//  Copyright © 2016 Martijn van Gogh. All rights reserved.
//

import UIKit

class CustomLeftBarbutton: UIButton {
   
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
        self.backgroundColor = .white
        self.setTitleColor(.red, for: .normal)
        self.titleLabel?.numberOfLines = 2
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        self.layer.cornerRadius = 20
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 4
        self.layer.masksToBounds = true
        self.titleLabel?.textAlignment = .center
        self.setTitle("Hide", for: .normal)
        self.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
    }

}
