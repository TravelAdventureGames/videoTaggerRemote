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
    //somecomment
    
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
    
    
    var viewController: ViewController?
    
    var tagpoints: [[String : AnyObject]] = []
    var tagPoint: [String:AnyObject] = [:] {
        didSet {
            print("tagpoint is \(tagPoint)")
            
            
        }
    }
    
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
                //do something
            })
        }
    }
    

    let controlsContainerView: UIView = {
       let cc = UIView()
        cc.backgroundColor = UIColor(white: 0, alpha: 1)
        return cc
        
    }()
    
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
    
    func setDictWithTouchedRow(beginTime: Double, endTime: Double) {
        let dict = ["bt": beginTime, "et": endTime]
        print("dict in touchedrow\(dict)")
        NotificationCenter.default.post(name: Notification.Name("SeekToTime"), object: dict)

    }
    
    func seekToSpecificTimeFrame(notification: NSNotification) {
        print(notification.object)
        
        if let myDict = notification.object as? [String: AnyObject] {
            if let beginTime = myDict["bt"] as? Double {
                let bt = Float64(beginTime)
                print(bt)
                let seekTime = CMTime(value: Int64(bt), timescale: 1)
                player?.seek(to: seekTime, completionHandler: { (completedSeek) in
                    if self.player != nil {
                        self.player?.pause()
                        let image = UIImage(named: "play")
                        self.playPauseButton.setImage(image, for: .normal)
                    }
                })
            }
        }
    }
    
    func addBeginGhostView() {
        setUpGhostViewWithColor(key: "begMult", color: .red, text: "S")
        
    }
    
    func addEndGhostView() {
        setUpGhostViewWithColor(key: "endMult", color: .purple, text: "E")
    }
    
    func setUpGhostViewWithColor(key: String, color: UIColor, text: String) {
        if let subs = UserDefaults.standard.array(forKey: "subscription") as? [[String: AnyObject]] {
            let tagPoints = subs as [[String : AnyObject]]
            
            for tagPoint in tagPoints {
                print("tagponits in addGhost \(tagPoint)")
                let begMult = tagPoint[key] as! CGFloat
                print(key)
                
                let stpv = UILabel()
                stpv.backgroundColor = color
                stpv.alpha = 0.7
                stpv.textAlignment = .center
                stpv.font = UIFont.boldSystemFont(ofSize: 8)
                stpv.text = text
                stpv.textColor = .white
                stpv.layer.cornerRadius = 6
                stpv.layer.masksToBounds = true
                stpv.translatesAutoresizingMaskIntoConstraints = false
                
                let constant = controlsContainerView.frame.width * begMult
                print("constant is \(constant)")
                
                tagPointsContainerView.addSubview(stpv)
                stpv.leftAnchor.constraint(equalTo: tagPointsContainerView.leftAnchor, constant: constant).isActive = true
                stpv.centerYAnchor.constraint(equalTo: tagPointsContainerView.centerYAnchor).isActive = true
                stpv.widthAnchor.constraint(equalToConstant: 12).isActive = true
                stpv.heightAnchor.constraint(equalToConstant: 12).isActive = true
                self.setNeedsDisplay()
            }
        }

    }
    
    func setUpPLayer() {
        let urlString = "https://firebasestorage.googleapis.com/v0/b/gameofchats-762ca.appspot.com/o/message_movies%2F12323439-9729-4941-BA07-2BAE970967C7.mov?alt=media&token=3e37a093-3bc8-410f-84d3-38332af9c726"
        guard let url = URL(string: urlString) else { return }
            player = AVPlayer(url: url)
        
            let playerLayer = AVPlayerLayer(player: player)
            self.layer.addSublayer(playerLayer)
//            playerLayer.bounds = controlsContainerView.layer.bounds
//            playerLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
            playerLayer.frame = CGRect(x: 0, y: 0, width: 640, height: 360)
            player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
            player?.pause()
            trackTime()

    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
            activityIndicatorView.stopAnimating()
            playPauseButton.isHidden = false
            controlsContainerView.backgroundColor = .clear
            
            
        }
    }
    
    func trackTime() {

        NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(seekToSpecificTimeFrame), name: Notification.Name("SeekToTime"), object: nil)
        
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
                    print("sm is \(self.startMultiplier)")
                    
                } else {
                    self.endTime = "\(minuteString):\(secondsString)"
                    self.endTimeSeconds = Double(progressedSeconds)
                    self.endMultiplier = Double(progressedSeconds / durationSeconds)
                    print("em is \(self.endMultiplier)")
                    
                    
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
        startPointView.topAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -8).isActive = true
        startPointView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        startPointView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        controlsContainerView.addSubview(endPointView)
        leftEndPointConstraint = endPointView.leftAnchor.constraint(equalTo: controlsContainerView.leftAnchor, constant: -20)
        leftEndPointConstraint.isActive = true
        endPointView.topAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -8).isActive = true
        endPointView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        endPointView.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        if let subs = UserDefaults.standard.array(forKey: "subscription") as? [[String: AnyObject]] {
            tagpoints = subs as [[String : AnyObject]]
            print("The videoView tagpoint are \(tagpoints)")
        }
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
   
    }
    
    var leftStartPointConstraint = NSLayoutConstraint()
    var leftEndPointConstraint = NSLayoutConstraint()
    
    override func awakeFromNib() {
        NotificationCenter.default.addObserver(self, selector: #selector(removeBeginAndEndpoint), name: Notification.Name("WasReset"), object: nil)
        setUpPLayer()
        for view in tagPointsContainerView.subviews {
            view.removeFromSuperview()
            }
        
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
        videoLengthSlider.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: 3).isActive = true
        
        addBeginGhostView()
        addEndGhostView()
    }
    
    override func layoutSubviews() {
        controlsContainerView.frame = self.bounds
    }

}
