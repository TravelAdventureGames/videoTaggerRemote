//
//  TagpointTableCell.swift
//  VideoTagger
//
//  Created by Martijn van Gogh on 07-12-16.
//  Copyright © 2016 Martijn van Gogh. All rights reserved.
//

import UIKit

class TagpointTableCell: UITableViewCell {
    
    let titleLabel: InsetLabel = {
        let tl = InsetLabel()
        tl.numberOfLines = 1
        tl.backgroundColor = UIColor(red: 203/255, green: 246/255, blue: 255/255, alpha: 0.6)
        tl.font = UIFont.boldSystemFont(ofSize: 16)
        tl.layer.masksToBounds = true
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    let commentLabel: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isSelectable = false
        tv.isScrollEnabled = false
        tv.font = UIFont.systemFont(ofSize: 13)
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.contentInset = UIEdgeInsetsMake(-4, -4, -4, 0)
        return tv
    }()
    
    var beginTimeLabel: UILabel = {
        let bl = UILabel()
        bl.backgroundColor = UIColor.white
        bl.translatesAutoresizingMaskIntoConstraints = false
        bl.text = "HH:MM:SS"
        bl.font = UIFont.boldSystemFont(ofSize: 9)
        bl.textAlignment = .center
        bl.layer.cornerRadius = 4
        bl.layer.masksToBounds = true
        return bl
    }()
    
    var endTimeLabel: UILabel = {
        let el = UILabel()
        el.backgroundColor = UIColor.white
        el.translatesAutoresizingMaskIntoConstraints = false
        el.text = "HH:MM:SS"
        el.font = UIFont.boldSystemFont(ofSize: 9)
        el.textAlignment = .center
        el.layer.cornerRadius = 4
        el.layer.masksToBounds = true
        return el
    }()
    
    let totalView: UIView = {
        let bv = UIView()
        bv.translatesAutoresizingMaskIntoConstraints = false
        bv.layer.borderWidth = 0.7
        bv.layer.borderColor = UIColor.gray.cgColor
        bv.layer.masksToBounds = true
        bv.layer.cornerRadius = 6
        return bv
    }()

    var commentHeightAnchor = NSLayoutConstraint()
    
    func setupConstraints() {
        addSubview(totalView)
        totalView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        totalView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        totalView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -12).isActive = true
        totalView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        totalView.addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: totalView.leftAnchor, constant: 0).isActive = true
        titleLabel.topAnchor.constraint(equalTo: totalView.topAnchor, constant: 0).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: totalView.rightAnchor, constant: 0).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        totalView.addSubview(beginTimeLabel)
        beginTimeLabel.topAnchor.constraint(equalTo: totalView.topAnchor, constant: 4).isActive = true
        beginTimeLabel.rightAnchor.constraint(equalTo: totalView.rightAnchor, constant: -4).isActive = true
        beginTimeLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        beginTimeLabel.heightAnchor.constraint(equalToConstant: 12).isActive = true
        
        totalView.addSubview(endTimeLabel)
        endTimeLabel.topAnchor.constraint(equalTo: beginTimeLabel.bottomAnchor, constant: 4).isActive = true
        endTimeLabel.rightAnchor.constraint(equalTo: totalView.rightAnchor, constant: -4).isActive = true
        endTimeLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        endTimeLabel.heightAnchor.constraint(equalToConstant: 12).isActive = true

        totalView.addSubview(commentLabel)
        commentLabel.leftAnchor.constraint(equalTo: totalView.leftAnchor, constant: 4).isActive = true
        commentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        commentLabel.rightAnchor.constraint(equalTo: totalView.rightAnchor, constant: 8).isActive = true
        commentLabel.heightAnchor.constraint(equalTo: totalView.heightAnchor).isActive = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setupConstraints()

        
    }

}
