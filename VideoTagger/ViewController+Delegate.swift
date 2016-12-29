//
//  ViewController+Delegate.swift
//  VideoTagger
//
//  Created by Martijn van Gogh on 12-12-16.
//  Copyright © 2016 Martijn van Gogh. All rights reserved.
//

import UIKit

extension ViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        videoView.removeImageDrawView()
        disAndEnableMultipleButtons(buttons: [startBtnLabel, endBtnLabel, submitBtnLabel, editBtn], dissAble: [false, true, true, true])
        if let selectedCell: TagpointTableCell = tableView.cellForRow(at: indexPath) as! TagpointTableCell? {
            let highlightedTag = videoView.titleTagDictArray[indexPath.row]
            let label = highlightedTag["label"] as! UILabel
            label.textColor = .gray
            label.layer.borderColor = UIColor.gray.cgColor
            label.layer.borderWidth = 0.5
            label.backgroundColor = .white
            
            selectedCell.titleLabel.backgroundColor = UIColor(red: 203/255, green: 246/255, blue: 255/255, alpha: 0.6)
            selectedCell.titleLabel.textColor = .black
            selectedCell.titleLabel.layer.masksToBounds = true
            selectedCell.endTimeLabel.backgroundColor = .white
            selectedCell.endTimeLabel.textColor = .black
            selectedCell.beginTimeLabel.backgroundColor = .white
            selectedCell.beginTimeLabel.textColor = .black
            selectedCell.totalView.layer.borderWidth = 0.7
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editBtn.isHidden = false
        isInEditMode = true
        titleTextField.isUserInteractionEnabled = false
        descriptionTextView.isUserInteractionEnabled = false
        disAndEnableMultipleButtons(buttons: [startBtnLabel, endBtnLabel, submitBtnLabel, editBtn, resetButton, newTagBtn, removeBtn], dissAble: [true, true, true, false, true, false, false])
        
        let tagPoint = tagPoints[indexPath.row]
        let imgData = tagPoint["drawImg"] as! Data
        let img = UIImage(data: imgData)
        videoView.drawImage = img!
        videoView.createDrawImageView()
        
        
        if let selectedCell: TagpointTableCell = tableView.cellForRow(at: indexPath) as! TagpointTableCell? {
            let highlightedTag = videoView.titleTagDictArray[indexPath.row]
            let label = highlightedTag["label"] as! UILabel
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = .white
            label.layer.borderWidth = 0.8
            label.layer.borderColor = UIColor.black.cgColor
            label.backgroundColor = .red
            label.layer.masksToBounds = true
            
            
            selectedCell.selectionStyle = .none
            selectedCell.titleLabel.backgroundColor = UIColor.red
            selectedCell.titleLabel.textColor = .white
            selectedCell.titleLabel.layer.masksToBounds = true
            selectedCell.endTimeLabel.backgroundColor = .white
            selectedCell.endTimeLabel.textColor = .black
            selectedCell.beginTimeLabel.backgroundColor = .white
            selectedCell.beginTimeLabel.textColor = .black
            selectedCell.totalView.layer.borderWidth = 1.2
            selectedCell.layer.shadowOffset = CGSize(width: 2, height: 2)
            selectedCell.layer.shadowRadius = 1
        }
        
        let tagpoint = tagPoints[indexPath.row]
        tagPoints[indexPath.row] = tagpoint
        let beginTime = tagpoint["beginTime"] as! Double
        guard let title = tagpoint["title"] else { return }
        guard let description = tagpoint["comment"] else { return }
        let endTime = tagpoint["endTime"] as! Double
        titleTextField.text = title as? String
        descriptionTextView.text = description as? String
        
        videoView.setDictWithTouchedRow(beginTime: beginTime, endTime: endTime)
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 100
        let tagpoint = tagPoints[indexPath.row]
        let comment = tagpoint["comment"] as! String
        height = estimateSizeOfCommentTextView(text: comment).height
        return height + 56
    }


}
