//
//  TagsTableviewLauncher.swift
//  VideoTagger
//
//  Created by Martijn van Gogh on 07-12-16.
//  Copyright © 2016 Martijn van Gogh. All rights reserved.
//

import UIKit
import AVFoundation

class TagsTableviewLauncher: NSObject {
    
    let cellId = "cellId"
    let videoView = VideoView()
    let tvWidth: CGFloat = 340
    var tagpoints: [[String : AnyObject]] = []
    
    let tableView: UITableView = {
        let tv = UITableView()
        return tv
    }()
    
    func handleShow(withDelay: TimeInterval ) {
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(tableView)
            
            tableView.frame = CGRect(x: -tvWidth, y: 134, width: tvWidth, height: 626)
            
            UIView.animate(withDuration: 0.5, delay: withDelay, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.tableView.frame = CGRect(x: 10, y: 134, width: self.tvWidth, height: 626)
                }, completion: nil)
        }
    }
    
    func handleDismiss() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.tableView.frame = CGRect(x: -self.tvWidth, y: 134, width: self.tvWidth, height: 626)
            }, completion: nil)
    }

    
    
    func getTimeString(time: Double) -> String {
        let secondsString = String(format: "%02d", Int(time .truncatingRemainder(dividingBy: 60)))
        let minuteString =  String(format: "%02d", Int(time / 60))
        return "\(minuteString):\(secondsString)"
    }
  
    override init() {
        super.init()
        

        if let subs = UserDefaults.standard.array(forKey: "subscription") as? [[String: AnyObject]] {
            tagpoints = subs as [[String : AnyObject]]
        }
        tableView.dataSource = self
        tableView.register(TagpointTableCell.self, forCellReuseIdentifier: cellId)
        
    }
}


