//
//  TagsTable+DataSource.swift
//  VideoTagger
//
//  Created by Martijn van Gogh on 12-12-16.
//  Copyright © 2016 Martijn van Gogh. All rights reserved.
//

import UIKit

extension TagsTableviewLauncher: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagpoints.count
    }
    
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tempDictArray = tagpoints.sorted {
            
            item1, item2 in
            let time1 = item1["beginTime"] as! Double
            let time2 = item2["beginTime"] as! Double
            return time1 < time2
        }
        tagpoints = tempDictArray
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TagpointTableCell
        let tagpoint = tagpoints[indexPath.row]
        let title = tagpoint["title"] as! String
        let comment = tagpoint["comment"] as! String
        let beginTime = tagpoint["beginTime"] as! Double
        let endTime = tagpoint["endTime"] as! Double
        
//        if let lsr = lastSelectedRow {
//            if lsr == indexPath.row {
//                let highlightedTag = videoView.titleTagDictArray[indexPath.row]
//                let label = highlightedTag["label"] as! UILabel
//                label.translatesAutoresizingMaskIntoConstraints = false
//                label.textColor = .white
//                label.layer.borderWidth = 0.8
//                label.layer.borderColor = UIColor.black.cgColor
//                label.backgroundColor = .red
//                label.layer.masksToBounds = true
//                
//                
//                cell.selectionStyle = .none
//                cell.titleLabel.backgroundColor = UIColor.red
//                cell.titleLabel.textColor = .white
//                cell.titleLabel.layer.masksToBounds = true
//                cell.endTimeLabel.backgroundColor = .white
//                cell.endTimeLabel.textColor = .black
//                cell.beginTimeLabel.backgroundColor = .white
//                cell.beginTimeLabel.textColor = .black
//                cell.totalView.layer.borderWidth = 1.2
//                cell.layer.shadowOffset = CGSize(width: 2, height: 2)
//                cell.layer.shadowRadius = 1
//            } else {
//                let highlightedTag = videoView.titleTagDictArray[indexPath.row]
//                let label = highlightedTag["label"] as! UILabel
//                label.textColor = .gray
//                label.layer.borderColor = UIColor.gray.cgColor
//                label.layer.borderWidth = 0.5
//                label.backgroundColor = .white
//                
//                cell.titleLabel.backgroundColor = UIColor(red: 203/255, green: 246/255, blue: 255/255, alpha: 0.6)
//                cell.titleLabel.textColor = .black
//                cell.titleLabel.layer.masksToBounds = true
//                cell.endTimeLabel.backgroundColor = .white
//                cell.endTimeLabel.textColor = .black
//                cell.beginTimeLabel.backgroundColor = .white
//                cell.beginTimeLabel.textColor = .black
//                cell.totalView.layer.borderWidth = 0.7
//            }
//    
//        }

        cell.titleLabel.text = title
        cell.commentLabel.text = comment
        cell.beginTimeLabel.text = getTimeString(time: beginTime)
        cell.endTimeLabel.text = getTimeString(time: endTime)
        
        return cell
    }
}
