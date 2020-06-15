//
//  BubbleView.swift
//  Sharkle
//
//  Created by cpsdqs on 2020-06-14.
//  Copyright © 2020 cpsdqs. All rights reserved.
//

import Cocoa

let BUBBLE_FRAME_COUNT = 2
let BUBBLE_FRAME_LEN = 4
let BUBBLE_FRAME = { (n: Int) -> String in "bubble\(n)" }

class BubbleView: NSView {
    var imageLayer = CALayer()

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        wantsLayer = true
        layer!.addSublayer(imageLayer)
        imageLayer.frame = NSMakeRect(0, 0, 196, 137)
    }

    var currentFrame = 0
    var inverted = false {
        didSet {
            imageLayer.compositingFilter = inverted ? CIFilter(name: "CIColorInvert") : nil
        }
    }

    func reset() {
        currentFrame = -1 // will be set to 0 in update
        update()
    }

    func update() {
        currentFrame += 1
        if currentFrame >= BUBBLE_FRAME_COUNT * BUBBLE_FRAME_LEN {
            currentFrame = 0
        }

        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        imageLayer.contents = NSImage(named: BUBBLE_FRAME(currentFrame / BUBBLE_FRAME_LEN))
        CATransaction.commit()
    }
    
}
