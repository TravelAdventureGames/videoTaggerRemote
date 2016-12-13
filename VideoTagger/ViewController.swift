//
//  ViewController.swift
//  VideoTagger
//
//  Created by Martijn van Gogh on 05-12-16.
//  Copyright © 2016 Martijn van Gogh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var tagPoints: [[String: AnyObject]] = [] {
        didSet {
            
        }
    }
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
        var someTags = Tagpoint.addUser(representation: <#T##AnyObject#>)
        
        
        tagsTableviewLauncher.tableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(enableSeekTime), name: Notification.Name("SeekToTime"), object: nil)
        
        if let subs = UserDefaults.standard.array(forKey: "subscription") as? [[String: AnyObject]] {
            tagPoints = subs as [[String : AnyObject]]
        }
        startBtnLabel.isEnabled = true
        endBtnLabel.isEnabled = false
        makeAllViewButtons()
        makeNavTitleViewWithImage()
        tagsTableviewLauncher.handleShow(withDelay: 0.5)
        makeLeftBarButtonItem()
        
        setUpTextViewAndField()
        
    }

    @IBAction func startTime(_ sender: AnyObject) {
        beginTimeWasSet = true
        endBtnLabel.isEnabled = true
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
        startBtnLabel.isEnabled = true
        endBtnLabel.isEnabled = false
        endTimeWasSet = false
        beginTimeWasSet = false
        titleTextField.text = nil
        descriptionTextView.text = nil
        NotificationCenter.default.post(name: Notification.Name("WasReset"), object: nil)
    }
    
    
    @IBAction func subMitTagPoint(_ sender: AnyObject) {
        print(isInEditMode)
        
        if isInEditMode {
            print("Is in deitingmode")
            if let selectedCell = selectedCellIndexpath {
                var tagpoint = tagPoints[selectedCell]
                tagpoint["title"] = titleTextField.text as AnyObject?
                tagpoint["comment"] = descriptionTextView.text as AnyObject?
                tagPoints[selectedCell] = tagpoint
                
                reloadTableView()
                clearAllInputFiels()
                isInEditMode = false

            }
            
        } else if titleTextField.text != "" && descriptionTextView.text != "" && beginTimeWasSet && endTimeWasSet  {
            guard let title = titleTextField.text, let comment = descriptionTextView.text, let beginTime = startTime, let endTime = endTime else { return }
            guard let sp = startPoint else { return }
            guard let ep = endPoint else { return }
            
            let tagPoint: [String: AnyObject] = ["title": title as AnyObject, "comment": comment as AnyObject, "beginTime": beginTime as AnyObject, "endTime": endTime as AnyObject, "begMult": sp as AnyObject,"endMult": ep as AnyObject]
            
            tagPoints.append(tagPoint as [String : AnyObject])
            startBtnLabel.isEnabled = true
            endBtnLabel.isEnabled = false
            
            reloadTableView()
            
            videoView.startPointView.isHidden = true
            videoView.endPointView.isHidden = true
            
            videoView.startTimeSet = false
            clearAllInputFiels()
            
            videoView.addEndGhostView()
            videoView.addBeginGhostView()
            
            beginTimeWasSet = false
            endTimeWasSet = true
            
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
    
    func reloadTableView() {
        tagsTableviewLauncher.tagpoints = tagPoints
        UserDefaults.standard.set(tagPoints, forKey: "subscription")
        tagsTableviewLauncher.tableView.reloadData()
    }
    
    
    @IBAction func createNewTag(_ sender: AnyObject) {
        clearAllInputFiels()
        switchToEditingMode(self)
        isInEditMode = false
        if let index = tagsTableviewLauncher.tableView.indexPathForSelectedRow {
            tagsTableviewLauncher.tableView.deselectRow(at: index, animated: true)
            if let selectedCell: TagpointTableCell = tagsTableviewLauncher.tableView.cellForRow(at: index) as! TagpointTableCell? {
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
    }
    
    @IBAction func switchToEditingMode(_ sender: AnyObject) {
        titleTextField.isUserInteractionEnabled = true
        descriptionTextView.isUserInteractionEnabled = true
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
        submitBtnLabel.setTitle("Submit", for: .normal)
        resetButton.setTitle("Reset", for: .normal)
        endBtnLabel.setTitle("Add end", for: .normal)
        guard let editImage = UIImage(named: "edit2")?.withRenderingMode(.alwaysOriginal) else { return }
        editBtn.setImage(editImage, for: .normal)
        editBtn.isHidden = true
        guard let newTagImg = UIImage(named: "newTag")?.withRenderingMode(.alwaysOriginal) else { return }
        newTagBtn.setImage(newTagImg, for: .normal)
    }
    
    func enableStartButton() {
        startBtnLabel.isEnabled = true
    }
    
    func makeLeftBarButtonItem() {
        button = CustomLeftBarbutton()
        button.addTarget(self, action: #selector(showAllTags), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = button
        navigationItem.leftBarButtonItem = rightBarButton
        
    }
    
    func showAllTags() {
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
}



