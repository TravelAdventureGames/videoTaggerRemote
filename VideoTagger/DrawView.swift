//
//  DrawView.swift
//  VideoTagger
//
//  Created by Martijn van Gogh on 27-12-16.
//  Copyright © 2016 Martijn van Gogh. All rights reserved.
//

import UIKit

class DrawView: UIView {

    var lines: [[String: CGPoint]]? = []
    var lastPoint: CGPoint!
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastPoint = touches.first?.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let newPoint = touches.first?.location(in: self)
        let points = ["start": lastPoint, "end": newPoint]
        lines!.append(points as! [String : CGPoint])
        lastPoint = newPoint
        setNeedsDisplay()
    
        
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.beginPath()
        for line in lines! {
            context?.move(to: CGPoint(x: line["start"]!.x, y: line["start"]!.y))
            context?.addLine(to: CGPoint(x: line["end"]!.x, y: line["end"]!.y))
            context?.setStrokeColor(UIColor.white.cgColor)
            context?.setLineWidth(3)
            context?.strokePath()
            
        }
        
    }
    
    


}
