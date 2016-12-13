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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TagpointTableCell
        let tagpoint = tagpoints[indexPath.row]
        print("Tableview Tagpoints \(tagpoint)")
        let title = tagpoint["title"] as! String
        let comment = tagpoint["comment"] as! String
        let beginTime = tagpoint["beginTime"] as! Double
        let endTime = tagpoint["endTime"] as! Double
        
        cell.titleLabel.text = title
        cell.commentLabel.text = comment
        cell.beginTimeLabel.text = getTimeString(time: beginTime)
        cell.endTimeLabel.text = getTimeString(time: endTime)
        
        return cell
    }
}
