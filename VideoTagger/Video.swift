//
//  Video.swift
//  VideoTagger
//
//  Created by Martijn van Gogh on 14-12-16.
//  Copyright © 2016 Martijn van Gogh. All rights reserved.
//

import UIKit

class Video {
    let allNames = ["Berenvideo", "Polar bears op jacht"]
    let allDurations = ["0:40","1:30"]
    let allUrls = ["https://firebasestorage.googleapis.com/v0/b/gameofchats-762ca.appspot.com/o/message_movies%2F12323439-9729-4941-BA07-2BAE970967C7.mov?alt=media&token=3e37a093-3bc8-410f-84d3-38332af9c726", "https://firebasestorage.googleapis.com/v0/b/gameofchats-762ca.appspot.com/o/message_movies%2F12323439-9729-4941-BA07-2BAE970967C7.mov?alt=media&token=3e37a093-3bc8-410f-84d3-38332af9c726"]
    
    var names: [String] = ["Berenvideo", "Polar bears op jacht"]
    var durations: [String] = ["0:40","1:30"]
    var urls: [String] = ["https://firebasestorage.googleapis.com/v0/b/gameofchats-762ca.appspot.com/o/message_movies%2F12323439-9729-4941-BA07-2BAE970967C7.mov?alt=media&token=3e37a093-3bc8-410f-84d3-38332af9c726", "https://firebasestorage.googleapis.com/v0/b/gameofchats-762ca.appspot.com/o/message_movies%2F12323439-9729-4941-BA07-2BAE970967C7.mov?alt=media&token=3e37a093-3bc8-410f-84d3-38332af9c726"]
    
    func allVideos() -> [Video] {
        let videos = [Video]()
        return videos
    }
    
        
    
}
