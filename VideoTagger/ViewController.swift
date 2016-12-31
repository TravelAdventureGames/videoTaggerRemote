//
//  ViewController.swift
//  VideoTagger
//
//  Created by Martijn van Gogh on 05-12-16.
//  Copyright © 2016 Martijn van Gogh. All rights reserved.
//

import UIKit
import MessageUI

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var tagPoints: [[String: AnyObject]] = []
    var allTagsShown = true
    var leftBarbutton = UIButton(type: .custom)
    var rightBarbutton = UIButton(type: .custom)
    var tagsTableviewLauncher = TagsTableviewLauncher()
    
    var startPoint: Double?
    var endPoint: Double?
    var startTime: Double?
    var endTime: Double?
    
    var beginTimeWasSet = false
    var endTimeWasSet = false
    
    var isInEditMode = false

    @IBOutlet var videoView: VideoView!
    
    @IBOutlet var drawButton: StartEndButton!
    @IBOutlet var fullScreenBtn: StartEndButton!
    @IBOutlet var removeBtn: StartEndButton!
    @IBOutlet var newTagBtn: UIButton!
    @IBOutlet var editBtn: UIButton!
    @IBOutlet var startBtnLabel: StartEndButton!
    @IBOutlet var endBtnLabel: StartEndButton!
    @IBOutlet var submitBtnLabel: StartEndButton!
    @IBOutlet var resetButton: StartEndButton!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!

    @IBOutlet var videoViewWidthConstraint: NSLayoutConstraint!
    var videoViewLrageWidthConstraint: NSLayoutConstraint?
    var videoViewLsmallWidthConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        videoViewLrageWidthConstraint = videoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7)
        videoViewLrageWidthConstraint?.isActive = false
 
        tagsTableviewLauncher.tableView.delegate = self
        tagsTableviewLauncher.tableView.separatorStyle = .none
        
        loadSavedTagpoints()
        disAndEnableMultipleButtons(buttons: [startBtnLabel, endBtnLabel, submitBtnLabel, editBtn, newTagBtn, removeBtn, drawButton, resetButton], dissAble: [false, true, true, true, true, true, true, true])
        
        makeAllViewButtons()
        makeNavTitleViewWithImage()
        tagsTableviewLauncher.handleShow(withDelay: 0.5)
        makeLeftBarButtonItem()
        setUpTextViewAndField()
        
    }
    
    override func viewDidLayoutSubviews() {
        videoView.createAllTagpointIndicatorViewsAboveVideo()
        videoView.drawView.frame = videoView.bounds
        videoView.imageDrawView.frame = videoView.bounds
    }

    @IBAction func startTime(_ sender: AnyObject) {
        beginTimeWasSet = true
        disAndEnableMultipleButtons(buttons: [endBtnLabel, startBtnLabel, submitBtnLabel, resetButton, drawButton, resetButton], dissAble: [false, true, true, false, false, false])
        videoView.handlePause()
        videoView.startTimeSet = true
        videoView.startPointView.isHidden = false
        startPoint = videoView.startMultiplier
        startTime = videoView.startTimeSeconds
        let size = Double(videoView.frame.width)
        let leftAnchorConstant = size * videoView.startMultiplier - 8
        videoView.leftStartPointConstraint.constant = CGFloat(leftAnchorConstant)
        videoView.removeDrawView()
        videoView.createDrawView()
    }

    @IBAction func endTime(_ sender: AnyObject) {
        disAndEnableMultipleButtons(buttons: [startBtnLabel, endBtnLabel, submitBtnLabel, drawButton], dissAble: [true, true, false, true])
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
            tagsTableviewLauncher.tagpoints = sortedTagpoints
            videoView.tagpoints = sortedTagpoints
            tagsTableviewLauncher.tableView.reloadData()
            videoView.createAllTagpointIndicatorViewsAboveVideo()
        }
    }
    
    func saveTagpointsToDefaults() {
        UserDefaults.standard.set(tagPoints, forKey: "subscription")
    }
    
    
    @IBAction func subMitTagPoint(_ sender: AnyObject) {
        NotificationCenter.default.addObserver(self, selector: #selector(enableSeekTime), name: Notification.Name("SeekToTime"), object: nil)
        disAndEnableMultipleButtons(buttons: [startBtnLabel, endBtnLabel, submitBtnLabel, editBtn], dissAble: [false, true, true, true])
        setSelectedTableViewCellToDeselected()
        if isInEditMode {
            if let index = tagsTableviewLauncher.tableView.indexPathForSelectedRow {
                tagsTableviewLauncher.tableView.deselectRow(at: index, animated: true)
                var tagpoint = tagPoints[index.row]
                tagpoint["title"] = titleTextField.text as AnyObject?
                tagpoint["comment"] = descriptionTextView.text as AnyObject?
                tagPoints[index.row] = tagpoint
                
                saveTagpointsToDefaults()
                loadSavedTagpoints()
                
                clearAllInputFiels()
                isInEditMode = false
                tagsTableviewLauncher.tableView.deselectRow(at: index, animated: true)
            }
            
        } else if titleTextField.text != "" && descriptionTextView.text != "" && beginTimeWasSet && endTimeWasSet  {
            videoView.createAndStoreImageFromDrawing()
            
            guard let title = titleTextField.text, let comment = descriptionTextView.text, let beginTime = startTime, let endTime = endTime else { return }
            guard let sp = startPoint else { return }
            guard let ep = endPoint else { return }
            guard let img = videoView.drawImage else { return }
            guard let imgData = UIImagePNGRepresentation(img) else { return }
            
            let tagPoint: [String: AnyObject] = ["title": title as AnyObject, "comment": comment as AnyObject, "beginTime": beginTime as AnyObject, "endTime": endTime as AnyObject, "begMult": sp as AnyObject,"endMult": ep as AnyObject, "drawImg": imgData as AnyObject]
            print("The tagpoint is \(tagPoint)")
            
            videoView.removeDrawView()

            tagPoints.append(tagPoint as [String : AnyObject])

            saveTagpointsToDefaults()
            loadSavedTagpoints()
            
            videoView.startPointView.isHidden = true
            videoView.endPointView.isHidden = true
            
            videoView.startTimeSet = false
            clearAllInputFiels()
            
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
        videoView.removeImageDrawView()
        setSelectedTableViewCellToDeselected()
        clearAllInputFiels()
        switchToEditingMode(self)
        disAndEnableMultipleButtons(buttons: [startBtnLabel, endBtnLabel, submitBtnLabel, editBtn, newTagBtn, removeBtn, drawButton, resetButton], dissAble: [false, true, true, true, true, true, true, true])
        isInEditMode = false
    }
    
    @IBAction func removeTagWithButton(_ sender: AnyObject) {
        videoView.removeImageDrawView()
        disAndEnableMultipleButtons(buttons: [startBtnLabel, endBtnLabel, submitBtnLabel, editBtn, newTagBtn, removeBtn, drawButton, resetButton], dissAble: [false, true, true, true, true, true, true, true])
        if let index = tagsTableviewLauncher.tableView.indexPathForSelectedRow {
            setSelectedTableViewCellToDeselected()
            tagPoints.remove(at: index.row)
            saveTagpointsToDefaults()
            loadSavedTagpoints()
            clearAllInputFiels()
        }
    }
    
    @IBAction func resetTimes(_ sender: AnyObject) {
        disAndEnableMultipleButtons(buttons: [startBtnLabel, endBtnLabel, submitBtnLabel, editBtn, newTagBtn, removeBtn, drawButton, resetButton], dissAble: [false, true, true, true, true, true, true, true])
        endTimeWasSet = false
        beginTimeWasSet = false
        videoView.startTimeSet = false
        titleTextField.text = nil
        descriptionTextView.text = nil
        videoView.removeDrawView()
        NotificationCenter.default.post(name: Notification.Name("WasReset"), object: nil)
    }
    @IBAction func switchFullScreenModus(_ sender: AnyObject) {
        showAndHideAllTagsTableView()
        
        if !allTagsShown {
            videoView.translatesAutoresizingMaskIntoConstraints = false
            videoViewWidthConstraint.isActive = false
            videoViewLrageWidthConstraint?.isActive = true
            
        } else {
            videoView.translatesAutoresizingMaskIntoConstraints = false
            videoViewLrageWidthConstraint?.isActive = false
            videoViewWidthConstraint.isActive = true
        }
    }
    @IBAction func createDrawView(_ sender: AnyObject) {
        videoView.removeDrawView()
        videoView.createDrawView()
        
    }

    @IBAction func switchToEditingMode(_ sender: AnyObject) {
        titleTextField.isUserInteractionEnabled = true
        descriptionTextView.isUserInteractionEnabled = true
        isInEditMode = true
        disAndEnableMultipleButtons(buttons: [startBtnLabel, endBtnLabel, submitBtnLabel], dissAble: [true, true, false, false])
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
        let size = CGSize(width: (view.frame.width * 0.25) - 16, height: 1000)
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
        editBtn.setTitle("Edit", for: .normal)
        newTagBtn.setTitle("New tag", for: .normal)
        removeBtn.setTitle("Delete", for: .normal)
        let img = UIImage(named: "fullscreen")?.withRenderingMode(.alwaysOriginal)
        fullScreenBtn.layer.masksToBounds = true
        fullScreenBtn.setImage(img, for: .normal)
        fullScreenBtn.contentEdgeInsets = UIEdgeInsetsMake(8,8,8,8)
        drawButton.setTitle("Draw", for: .normal)
        
    }

    func makeLeftBarButtonItem() {
        leftBarbutton = CustomLeftBarbutton()
        leftBarbutton.addTarget(self, action: #selector(showAndHideAllTagsTableView), for: .touchUpInside)
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftBarbutton
        navigationItem.leftBarButtonItem = leftBarButton
        
        rightBarbutton = CustomLeftBarbutton()
        rightBarbutton.setTitle("Mail", for: .normal)
        rightBarbutton.addTarget(self, action: #selector(exportEmail), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = rightBarbutton
        navigationItem.rightBarButtonItem = rightBarButton
 
    }

    func exportEmail() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        var emailBody = "De volgende fragmenten werden als waardevol bestempeld door de observant:"
        for tp in tagPoints {
            let beginTime = tp["beginTime"] as! Double
            let (bhr, bmin, bsec) = beginTime.secondsToHoursMinutesSeconds()
            let endTime = tp["endTime"] as! Double
            let (ehr, emin, esec) = endTime.secondsToHoursMinutesSeconds()
            let title = tp["title"] as! String
            let description = tp["comment"] as! String
            
            //let et = Double(round(endTime*10)/10)
            emailBody += "\n\n\(title): Starttijd: \(bhr):\(bmin):\(bsec), Eindtijd \(ehr):\(emin):\(esec)\n\(description)"
        }
        
        print(emailBody)
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["martijn@traveladventuregames.nl"])
        mailComposerVC.setSubject("Proces verbaal film")
        mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let alert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    func showAndHideAllTagsTableView() {
        if !allTagsShown {
            leftBarbutton.setTitle("Hide", for: .normal)
            tagsTableviewLauncher.handleShow(withDelay: 0)
            
        } else {
            leftBarbutton.setTitle("Show", for: .normal)
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
                button.alpha = 0.3
            case false:
                button.isEnabled = true
                button.alpha = 1.0
            }
            
        }
    }
}



