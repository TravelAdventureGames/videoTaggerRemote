//
//  ViewController.swift
//  VideoTagger
//
//  Created by Martijn van Gogh on 05-12-16.
//  Copyright © 2016 Martijn van Gogh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var tagPoints: [[String: AnyObject]] = [] 
    var allTagsShown = true
    var button = UIButton(type: .custom)
    var tagsTableviewLauncher = TagsTableviewLauncher()
    
    var startPoint: Double?
    var endPoint: Double?
    var startTime: Double?
    var endTime: Double?
    
    var beginTimeWasSet = false
    var endTimeWasSet = false
    
    var isInEditMode = false
    var selectedCellIndexpath: Int?
    
    var modelTagpoints: [Tagpoint]?

    @IBOutlet var videoView: VideoView!
    
    @IBOutlet var newTagBtn: UIButton!
    @IBOutlet var editBtn: UIButton!
    @IBOutlet var startBtnLabel: StartEndButton!
    @IBOutlet var endBtnLabel: StartEndButton!
    @IBOutlet var submitBtnLabel: StartEndButton!
    @IBOutlet var resetButton: StartEndButton!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tagsTableviewLauncher.tableView.delegate = self
        tagsTableviewLauncher.tableView.separatorStyle = .none
        NotificationCenter.default.addObserver(self, selector: #selector(enableSeekTime), name: Notification.Name("SeekToTime"), object: nil)
        
        loadSavedTagpoints()
        disAndEnableMultipleButtons(buttons: [startBtnLabel, endBtnLabel], dissAble: [false, true])
        
        makeAllViewButtons()
        makeNavTitleViewWithImage()
        tagsTableviewLauncher.handleShow(withDelay: 0.5)
        makeLeftBarButtonItem()
        setUpTextViewAndField()
        
    }

    @IBAction func startTime(_ sender: AnyObject) {
        beginTimeWasSet = true
        disAndEnableMultipleButtons(buttons: [endBtnLabel, startBtnLabel], dissAble: [false, true])
        videoView.handlePause()
        videoView.startTimeSet = true
        videoView.startPointView.isHidden = false
        startPoint = videoView.startMultiplier
        startTime = videoView.startTimeSeconds
        let size = Double(videoView.frame.width)
        let leftAnchorConstant = size * videoView.startMultiplier - 8
        videoView.leftStartPointConstraint.constant = CGFloat(leftAnchorConstant)

    }

    @IBAction func endTime(_ sender: AnyObject) {
        disAndEnableMultipleButtons(buttons: [startBtnLabel, endBtnLabel], dissAble: [true, true])
        endTimeWasSet = true
        videoView.handlePause()
        videoView.endPointView.isHidden = false
        let size = Double(videoView.frame.width)
        let leftAnchorConstant = size * videoView.endMultiplier
        endPoint = videoView.endMultiplier
        endTime = videoView.endTimeSeconds
        videoView.leftEndPointConstraint.constant = CGFloat(leftAnchorConstant) - 8
        videoView.startTimeSet = false
        
    }
    
    @IBAction func resetTimes(_ sender: AnyObject) {
        disAndEnableMultipleButtons(buttons: [startBtnLabel, endBtnLabel], dissAble: [false, true])
        endTimeWasSet = false
        beginTimeWasSet = false
        titleTextField.text = nil
        descriptionTextView.text = nil
        NotificationCenter.default.post(name: Notification.Name("WasReset"), object: nil)
    }
    
    func loadSavedTagpoints() {
        if let subs = UserDefaults.standard.array(forKey: "subscription") as? [[String: AnyObject]] {
            let tagpoints = subs as [[String : AnyObject]]
            let sortedTagpoints = tagpoints.sorted {
                item1, item2 in
                let time1 = item1["begMult"] as! Double
                let time2 = item2["begMult"] as! Double
                return time1 < time2
            }
            tagPoints = sortedTagpoints
        }
    }
    
    func saveTagpointsAndReloadTableView() {
        tagsTableviewLauncher.tagpoints = tagPoints
        videoView.tagpoints = tagPoints
        UserDefaults.standard.set(tagPoints, forKey: "subscription")
        tagsTableviewLauncher.tableView.reloadData()
    }
    
    
    @IBAction func subMitTagPoint(_ sender: AnyObject) {
        setSelectedTableViewCellToDeselected()
        disAndEnableMultipleButtons(buttons: [startBtnLabel, endBtnLabel], dissAble: [false, true])
        if isInEditMode {
            if let index = tagsTableviewLauncher.tableView.indexPathForSelectedRow {
                tagsTableviewLauncher.tableView.deselectRow(at: index, animated: true)
                var tagpoint = tagPoints[index.row]
                tagpoint["title"] = titleTextField.text as AnyObject?
                tagpoint["comment"] = descriptionTextView.text as AnyObject?
                tagPoints[index.row] = tagpoint
                saveTagpointsAndReloadTableView()
                loadSavedTagpoints()
                videoView.createAllTagpointIndicatorViewsAboveVideo()
                clearAllInputFiels()
                isInEditMode = false
            }
            
        } else if titleTextField.text != "" && descriptionTextView.text != "" && beginTimeWasSet && endTimeWasSet  {
            guard let title = titleTextField.text, let comment = descriptionTextView.text, let beginTime = startTime, let endTime = endTime else { return }
            guard let sp = startPoint else { return }
            guard let ep = endPoint else { return }
            
            let tagPoint: [String: AnyObject] = ["title": title as AnyObject, "comment": comment as AnyObject, "beginTime": beginTime as AnyObject, "endTime": endTime as AnyObject, "begMult": sp as AnyObject,"endMult": ep as AnyObject]
           
            
            tagPoints.append(tagPoint as [String : AnyObject])
            
            saveTagpointsAndReloadTableView()
            
            videoView.startPointView.isHidden = true
            videoView.endPointView.isHidden = true
            
            videoView.startTimeSet = false
            clearAllInputFiels()
            
            loadSavedTagpoints()
            videoView.createAllTagpointIndicatorViewsAboveVideo()
            
            beginTimeWasSet = false
            endTimeWasSet = false
            
            } else {
                let alert = UIAlertController(title: "Not complete", message: "Please fill in a title and a comment and be sure to select a begin- and endpoint for the fragment.", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
  
    }
    func clearAllInputFiels() {
        titleTextField.text = nil
        descriptionTextView.text = nil
        
    }
    
    
    @IBAction func createNewTag(_ sender: AnyObject) {
        clearAllInputFiels()
        switchToEditingMode(self)
        disAndEnableMultipleButtons(buttons: [startBtnLabel, endBtnLabel], dissAble: [false, true])
        isInEditMode = false
        setSelectedTableViewCellToDeselected()
        
        
    }
    
    @IBAction func switchToEditingMode(_ sender: AnyObject) {
        titleTextField.isUserInteractionEnabled = true
        descriptionTextView.isUserInteractionEnabled = true
        disAndEnableMultipleButtons(buttons: [startBtnLabel, endBtnLabel], dissAble: [true, true])
        
        
    }
    //Helper func to set selected cell-layout to deselcted
    func setSelectedTableViewCellToDeselected() {
        if let index = tagsTableviewLauncher.tableView.indexPathForSelectedRow {
            if let selectedCell: TagpointTableCell = tagsTableviewLauncher.tableView.cellForRow(at: index) as! TagpointTableCell? {
                selectedCell.titleLabel.backgroundColor = UIColor(red: 203/255, green: 246/255, blue: 255/255, alpha: 0.6)
                selectedCell.titleLabel.textColor = .black
                selectedCell.titleLabel.layer.masksToBounds = true
                selectedCell.endTimeLabel.backgroundColor = .white
                selectedCell.endTimeLabel.textColor = .black
                selectedCell.beginTimeLabel.backgroundColor = .white
                selectedCell.beginTimeLabel.textColor = .black
                selectedCell.totalView.layer.borderWidth = 0.7
                
                let highlightedTag = videoView.titleTagDictArray[index.row]
                let label = highlightedTag["label"] as! UILabel
                label.textColor = .gray
                label.layer.borderColor = UIColor.gray.cgColor
                label.layer.borderWidth = 0.5
                label.backgroundColor = .white
            }
            
        }
    }

    
    func estimateSizeOfCommentTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 13)], context: nil)
    }
    
    
    func enableSeekTime() {
        tagsTableviewLauncher.tableView.isUserInteractionEnabled = true
    }
    
    func makeNavTitleViewWithImage() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 38))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "politielogo")?.withRenderingMode(.alwaysTemplate)
        imageView.image = image
        navigationItem.titleView = imageView
    }
    
    func makeAllViewButtons() {
        submitBtnLabel.layer.cornerRadius = 12
        submitBtnLabel.setTitle("Save", for: .normal)
        resetButton.setTitle("Reset", for: .normal)
        endBtnLabel.setTitle("Add end", for: .normal)
        guard let editImage = UIImage(named: "edit2")?.withRenderingMode(.alwaysOriginal) else { return }
        editBtn.setImage(editImage, for: .normal)
        editBtn.isHidden = true
        guard let newTagImg = UIImage(named: "newTag")?.withRenderingMode(.alwaysOriginal) else { return }
        newTagBtn.setImage(newTagImg, for: .normal)
    }

    func makeLeftBarButtonItem() {
        button = CustomLeftBarbutton()
        button.addTarget(self, action: #selector(showAndHideAllTagsTableView), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = button
        navigationItem.leftBarButtonItem = rightBarButton
        
    }
    
    func showAndHideAllTagsTableView() {
        if !allTagsShown {
            button.setTitle("Hide", for: .normal)
            tagsTableviewLauncher.handleShow(withDelay: 0)
            
        } else {
            button.setTitle("Show", for: .normal)
            tagsTableviewLauncher.handleDismiss()
        }
        allTagsShown = !allTagsShown
    }

    func setUpTextViewAndField() {
        descriptionTextView.layer.cornerRadius = 12
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.borderColor = UIColor(red: 120/255, green: 120/255, blue: 120/255, alpha: 0.5).cgColor
    }
    
    
    func disAndEnableMultipleButtons(buttons: [UIButton], dissAble: [Bool]) {
        for (index, button) in buttons.enumerated() {
            switch dissAble[index] {
            case true:
                button.isEnabled = false
                button.alpha = 0.5
            case false:
                button.isEnabled = true
                button.alpha = 1.0
            }
            
        }
    }
}



