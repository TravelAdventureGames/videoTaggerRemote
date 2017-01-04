//
//  VideoView.swift
//  VideoTagger
//
//  Created by Martijn van Gogh on 05-12-16.
//  Copyright © 2016 Martijn van Gogh. All rights reserved.
//

import UIKit
import AVFoundation

class VideoView: UIView {
    
    var player: AVPlayer?
    var startTime: String = ""
    var endTime: String = ""
    var endTimeSeconds: Double!
    var startTimeSeconds: Double!
    var startTimeSet = false
    var startMultiplier: Double!
    var endMultiplier: Double!
    var didSelectTagpoint: NSObject!
    var totalDuration: CMTime?
    var beginTimeSeekToFrame: Float64 = 10
    var counter = 0
    
    var playerLayer = AVPlayerLayer()
    
    var titleTagLabelArray: [UILabel] = []
    var titleTagDictArray: [[String: AnyObject]] = []
 
    var viewController: ViewController?
    var tagsTableViewController: TagsTableviewLauncher?
    
    var tagpoints: [[String : AnyObject]] = []
    var drawImage: UIImage?
    
    var tagPoint: [String:AnyObject] = [:]
    
    lazy var videoLengthSlider: UISlider = {
        let sl = UISlider()
        sl.minimumTrackTintColor = .red
        sl.setThumbImage(UIImage(named: "reddot3"), for: .normal)
        sl.translatesAutoresizingMaskIntoConstraints = false
        sl.maximumTrackTintColor = .white
        sl.addTarget(self, action: #selector(handleSliderChange), for: UIControlEvents.valueChanged)
        
        return sl
    }()
    
    func handleSliderChange() {
        if let totalDuration = player?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(totalDuration)
            let currentVideoTime = Float64(videoLengthSlider.value) * totalSeconds
            let seekTime = CMTime(value: Int64(currentVideoTime), timescale: 1)
            player?.seek(to: seekTime, completionHandler: { (completedSeek) in
            })
        }
    }
    
    let controlsContainerView: UIView = {
       let cc = UIView()
        cc.backgroundColor = UIColor(white: 0, alpha: 1)
        return cc
        
    }()
    
    let drawView = DrawView()
    let imageDrawView = UIImageView()
    
    let tagPointsContainerView: UIView = {
        let tv = UIView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        return tv
    }()
    
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.startAnimating()
        return aiv
    }()
    
    lazy var playPauseButton: UIButton = {
        let ppb = UIButton(type: UIButtonType.custom)
        let image = UIImage(named: "play")
        ppb.setImage(image, for: .normal)
        ppb.tintColor = .white
        ppb.isHidden = true
        ppb.translatesAutoresizingMaskIntoConstraints = false
        ppb.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        return ppb
    }()
    
    let startPointView: UILabel = {
        let stpv = UILabel()
        stpv.layer.cornerRadius = 8
        stpv.backgroundColor = .red
        stpv.textAlignment = .center
        stpv.text = "S"
        stpv.textColor = .white
        stpv.layer.masksToBounds = true
        stpv.translatesAutoresizingMaskIntoConstraints = false
        stpv.isHidden = true
        return stpv
    }()
    
    let endPointView: UILabel = {
        let stpv = UILabel()
        stpv.layer.cornerRadius = 8
        stpv.backgroundColor = .purple
        stpv.textAlignment = .center
        stpv.text = "E"
        stpv.textColor = .white
        stpv.layer.masksToBounds = true
        stpv.translatesAutoresizingMaskIntoConstraints = false
        stpv.isHidden = true
        return stpv
    }()
    
    let detailView = DetailView()
    
    override func layoutSublayers(of layer: CALayer) {
        playerLayer.frame = self.bounds
        controlsContainerView.frame = self.bounds
    }

    func setDictWithTouchedRow(beginTime: Double, endTime: Double) {
        let dict = ["bt": beginTime, "et": endTime]
        NotificationCenter.default.post(name: Notification.Name("SeekToTime"), object: dict)

    }
    
    func loadSavedTagpoints() {
        if let subs = UserDefaults.standard.array(forKey: "subscription") as? [[String: AnyObject]] {
            var tagpoints = subs as [[String : AnyObject]]
            let sortedTagpoints = tagpoints.sorted {
                item1, item2 in
                let time1 = item1["begMult"] as! Double
                let time2 = item2["begMult"] as! Double
                return time1 < time2
            }
            tagpoints = sortedTagpoints
        }
    }
    
    func createAndStoreImageFromDrawing() {
        drawImage = nil
        let renderer = UIGraphicsImageRenderer(size: drawView.bounds.size)
        let image = renderer.image { ctx in
            drawView.drawHierarchy(in: drawView.bounds, afterScreenUpdates: true)
            }
        drawImage = image
    }
    
    
    func createDrawView() {
        drawView.lines? = []
        drawView.frame = self.bounds
        drawView.backgroundColor = .clear
        controlsContainerView.insertSubview(drawView, belowSubview: playPauseButton)
        //addSubview(drawView)
        drawView.setNeedsDisplay()
        
    }

    func removeDrawView() {
        drawView.lines?.removeAll()
        drawView.removeFromSuperview()
        setNeedsDisplay()
    }
    
    func createDrawImageView() {
       if drawImage != nil {
            imageDrawView.frame = self.bounds
            imageDrawView.backgroundColor = .clear
            addSubview(imageDrawView)
            imageDrawView.image = drawImage
            imageDrawView.contentMode = .scaleAspectFill
      }
        
    }
    func removeImageDrawView() {
        imageDrawView.removeFromSuperview()
        setNeedsDisplay()
    }

    var labelWidthAnchor = NSLayoutConstraint()
    var labelHeightAnchor = NSLayoutConstraint()
    
    
    func createAllTagpointIndicatorViewsAboveVideo() {
        counter = 0
        if let subs = UserDefaults.standard.array(forKey: "subscription") as? [[String: AnyObject]] {
            let tagPoints = subs as [[String : AnyObject]]
            let sortedTagpoints = tagPoints.sorted {
                item1, item2 in
                let time1 = item1["begMult"] as! Double
                let time2 = item2["begMult"] as! Double
                return time1 < time2
            }
            tagpoints = sortedTagpoints
        
            for view in tagPointsContainerView.subviews {
                view.removeFromSuperview()
            }
            titleTagDictArray.removeAll()
            var heightOfLineView: CGFloat = 0
            
            for tagPoint in tagpoints {

                let begMult = tagPoint["begMult"] as! CGFloat
                let tagName = tagPoint["title"] as! String
                
                if counter < 5 {
                    counter += 1
                } else {
                    counter = 1
                }
                
                switch counter {
                    case 1:
                       heightOfLineView = 10
                    case 2:
                        heightOfLineView = 20
                    case 3:
                        heightOfLineView = 30
                    case 4:
                        heightOfLineView = 40
                    case 5:
                        heightOfLineView = 50
                    default:
                        break
                }

                let constant = self.frame.width * begMult
                
                let lineView = UIView()
                lineView.backgroundColor = .gray
                lineView.alpha = 0.7
                lineView.translatesAutoresizingMaskIntoConstraints = false
                
                tagPointsContainerView.addSubview(lineView)
                lineView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: constant).isActive = true
                lineView.bottomAnchor.constraint(equalTo: tagPointsContainerView.topAnchor, constant: 3).isActive = true
                lineView.widthAnchor.constraint(equalToConstant: 1).isActive = true
                lineView.heightAnchor.constraint(equalToConstant: heightOfLineView).isActive = true
                self.setNeedsDisplay()
                
                let label = UILabel()
                label.backgroundColor = .white
                label.layer.borderColor = UIColor.gray.cgColor
                label.textColor = .gray
                label.layer.borderWidth = 0.5
                label.layer.cornerRadius = 3
                label.alpha = 1.0
                label.textAlignment = .center
                label.font = UIFont.boldSystemFont(ofSize: 8)
                label.textColor = .black
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = tagName

                tagPointsContainerView.addSubview(label)
                label.bottomAnchor.constraint(equalTo: tagPointsContainerView.topAnchor, constant: -heightOfLineView + 3).isActive = true
                label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: constant).isActive = true
                
                labelWidthAnchor = label.widthAnchor.constraint(equalToConstant: 80)
                labelWidthAnchor.isActive = true
                
                labelHeightAnchor = label.heightAnchor.constraint(equalToConstant: 10)
                labelHeightAnchor.isActive = true
                
                let titleTagDict = ["begin": begMult, "label": label] as [String : Any]
                titleTagDictArray.append(titleTagDict as [String : AnyObject])
                
                self.setNeedsDisplay()
            }
            
            let tempDictArray = titleTagDictArray.sorted {
                
                item1, item2 in
                let time1 = item1["begin"] as! Double
                let time2 = item2["begin"] as! Double
                return time1 < time2
            }
            titleTagDictArray = tempDictArray
            
//            if let index = tagsTableViewController?.tableView.indexPathForSelectedRow {
//                let lbl = titleTagDictArray[index.row]
//                let myLabel = lbl["label"] as! UILabel
//                myLabel.backgroundColor = .red
//                myLabel.textColor = .white
//            
//            }
        }

    }
    
    func setUpPLayer() {
        let urlString = "https://firebasestorage.googleapis.com/v0/b/gameofchats-762ca.appspot.com/o/message_movies%2F12323439-9729-4941-BA07-2BAE970967C7.mov?alt=media&token=3e37a093-3bc8-410f-84d3-38332af9c726" //"https://firebasestorage.googleapis.com/v0/b/videotrack-83e0d.appspot.com/o/lego.mov?alt=media&token=84f70a09-11d0-4406-bdfb-a8201ac54cb9"//
        
        guard let url = URL(string: urlString) else { return }
            player = AVPlayer(url: url)
        
            playerLayer = AVPlayerLayer(player: player)
            self.layer.addSublayer(playerLayer)
        
            //playerLayer.frame = CGRect(x: 0, y: 0, width: 640, height: 360)
            player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
            player?.pause()
            trackTime()

    }
    // To check if the video was loaded
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
            activityIndicatorView.stopAnimating()
            playPauseButton.isHidden = false
            controlsContainerView.backgroundColor = .clear
            
         
        }
    }
    func seekToSpecificTimeFrame(notification: NSNotification) {
        
        if let myDict = notification.object as? [String: AnyObject] {
            
            if let beginTime = myDict["bt"] as? Double {
                print("The selected begintime on a row tap is \(beginTime)")
                let bt = Float64(beginTime)
                let seekTime = CMTime(value: Int64(bt), timescale: 1)
                print("The seektime is \(seekTime)")
                player?.seek(to: seekTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (completedseek) in
                    if self.player != nil {
                        self.player?.pause()
                        let image = UIImage(named: "play")
                        self.playPauseButton.setImage(image, for: .normal)
                        
                        if let duration = self.player?.currentItem?.duration {
                            let durationSeconds = CMTimeGetSeconds(duration)
                            self.videoLengthSlider.value = Float(beginTime / durationSeconds)
                        }
                    }
                })
            }
        }
    }
    
    func trackTime() {

        NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(self.seekToSpecificTimeFrame), name: Notification.Name("SeekToTime"), object: nil)
        
        
        let interval = CMTime(value: 1, timescale: 20)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressedTime) in

            let progressedSeconds = CMTimeGetSeconds(progressedTime)
            let secondsString = String(format: "%02d", Int(progressedSeconds .truncatingRemainder(dividingBy: 60)))
            let minuteString =  String(format: "%02d", Int(progressedSeconds / 60))
            

            if let duration = self.player?.currentItem?.duration {

                let durationSeconds = CMTimeGetSeconds(duration)
                self.videoLengthSlider.value = Float(progressedSeconds / durationSeconds)
                
                if self.startTimeSet == false {
                    self.startTime = "\(minuteString):\(secondsString)"
                    self.startTimeSeconds = Double(progressedSeconds)
                    self.startMultiplier = Double(progressedSeconds / durationSeconds)  
                    
                } else {
                    self.endTime = "\(minuteString):\(secondsString)"
                    self.endTimeSeconds = Double(progressedSeconds)
                    self.endMultiplier = Double(progressedSeconds / durationSeconds)
   
                }
            }
        })
    }
    
    func finishedPlaying() {
        player?.seek(to: kCMTimeZero, completionHandler: { (done) in
            
        })
    }
    
    var isPLaying = false
    
    func handlePause() {
        if isPLaying {
            player?.pause()
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        } else {
            player?.play()
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        }
        
        isPLaying = !isPLaying
        
    }
    
    //called when reset button is pressed via notification. Removes last 2 tagpoints
    func removeBeginAndEndpoint() {
        endPointView.removeFromSuperview()
        startPointView.removeFromSuperview()
        addStartAndEndViews()
        startPointView.isHidden = true
        endPointView.isHidden = true
    }
    
    func addStartAndEndViews() {
        controlsContainerView.addSubview(startPointView)
        leftStartPointConstraint = startPointView.leftAnchor.constraint(equalTo: controlsContainerView.leftAnchor, constant: -20)
        leftStartPointConstraint.isActive = true
        startPointView.topAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: 0).isActive = true
        startPointView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        startPointView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        controlsContainerView.addSubview(endPointView)
        leftEndPointConstraint = endPointView.leftAnchor.constraint(equalTo: controlsContainerView.leftAnchor, constant: -20)
        leftEndPointConstraint.isActive = true
        endPointView.topAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: 0).isActive = true
        endPointView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        endPointView.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadSavedTagpoints()

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
   
    }
    
    var leftStartPointConstraint = NSLayoutConstraint()
    var leftEndPointConstraint = NSLayoutConstraint()
    
    override func awakeFromNib() {
        NotificationCenter.default.addObserver(self, selector: #selector(removeBeginAndEndpoint), name: Notification.Name("WasReset"), object: nil)
        setUpPLayer()
        
        self.addSubview(controlsContainerView)
        controlsContainerView.frame = CGRect(x: 0, y: 0, width: 640, height: 360)
        
        controlsContainerView.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        self.addSubview(tagPointsContainerView)
        tagPointsContainerView.leftAnchor.constraint(equalTo: controlsContainerView.leftAnchor, constant: 0).isActive = true
        tagPointsContainerView.bottomAnchor.constraint(equalTo: controlsContainerView.topAnchor, constant: 8).isActive = true
        tagPointsContainerView.widthAnchor.constraint(equalTo: controlsContainerView.widthAnchor).isActive = true
        tagPointsContainerView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        
        addStartAndEndViews()

        controlsContainerView.addSubview(playPauseButton)
        playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        playPauseButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        playPauseButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        controlsContainerView.addSubview(videoLengthSlider)
        videoLengthSlider.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        videoLengthSlider.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        videoLengthSlider.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: 4).isActive = true
        
        createAllTagpointIndicatorViewsAboveVideo()
    }
    
    override func layoutSubviews() {
        controlsContainerView.frame = self.bounds
        self.frame = self.frame
        drawView.frame = self.bounds
    }

}

extension UILabel{
    
    func requiredWidth() -> CGFloat{
        
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: self.frame.height))
        label.numberOfLines = 1
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        return label.frame.height
    }
}
