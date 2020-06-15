//
//  BubbleView.swift
//  Sharkle
//
//  Created by cpsdqs on 2020-06-14.
//  Copyright © 2020 cpsdqs. All rights reserved.
//

import Cocoa

/// Number of frames in the bubble animation.
let BUBBLE_FRAME_COUNT = 2
/// Length of a single animation frame, in frames.
let BUBBLE_FRAME_LEN = 4
/// Bubble frame resource name.
let BUBBLE_FRAME = { (n: Int) -> String in "bubble\(n)" }

/// The “SHARKLE” speech bubble.
class BubbleView: NSView {
    /// CALayer into which the actual image will be drawn.
    /// Setting contents on the NSView's layer causes compositing issues when using the invert filter.
    var imageLayer = CALayer()

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        wantsLayer = true
        layer!.addSublayer(imageLayer)
        imageLayer.frame = NSMakeRect(0, 0, 196, 137)
    }

    /// Current animation frame.
    var currentFrame = 0
    /// If true, the bubble will be drawn inverted.
    var inverted = false {
        didSet {
            imageLayer.compositingFilter = inverted ? CIFilter(name: "CIColorInvert") : nil
        }
    }

    /// Resets the bubble animation.
    func reset() {
        currentFrame = -1 // will be set to 0 in update
        update()
    }

    /// Updates the animation.
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
