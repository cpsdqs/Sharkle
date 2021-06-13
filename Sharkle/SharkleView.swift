//
//  SharkleView.swift
//  Sharkle
//
//  Created by cpsdqs on 2020-06-14.
//  Copyright © 2020 cpsdqs. All rights reserved.
//

import Cocoa

let IDLE_FRAME_COUNT = 8
let SAY_FRAME_COUNT = 4
let IDLE_FRAME = { (n: Int) -> String in "idle\(n)" }
let SAY_FRAME = { (n: Int) -> String in n == 3 ? "say1" : "say\(n)" }
let SAY_DURATION = 16
let SHARKLE_FRAME_DURATION = 0.1
let SHARKLE_SOUND_COUNT = 7
let SHARKLE_SOUND_NAME = { (n: Int) -> String in "sound\(n)" }

class SharkleView: NSView {
    /// CALayer into which the image will be drawn.
    /// This exists because the Sharkle image resource has large margins.
    let imageLayer = CALayer()

    /// Animation timer.
    var frameTimer: Timer?

    /// The accompanying bubble view.
    weak var bubbleView: BubbleView?
    
    /// The owning window's controller.
    weak var windowController: SharkleWindowController?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true

        layer!.addSublayer(imageLayer)

        imageLayer.frame = NSMakeRect(-42, -24, 270, 270)

        frameTimer = Timer.scheduledTimer(
            withTimeInterval: SHARKLE_FRAME_DURATION,
            repeats: true
        ) { timer in self.update() }
        frameTimer!.tolerance = .infinity

        update()
    }

    /// The last sound ID, to ensure that no sound is played twice in succession.
    var lastSharkleSoundId = -1

    override func mouseDown(with event: NSEvent) {
        if isSaying {
            return
        }

        var soundId = lastSharkleSoundId
        while soundId == lastSharkleSoundId {
            soundId = Int(arc4random()) % SHARKLE_SOUND_COUNT
        }
        lastSharkleSoundId = soundId
        let soundData = NSDataAsset(name: SHARKLE_SOUND_NAME(soundId))!
        let sound = NSSound(data: soundData.data)
        sound!.play()

        isSaying = true
        sayTimeout = SAY_DURATION
        currentFrame = 0
        bubbleView?.reset()
    }
    
    override func scrollWheel(with event: NSEvent) {
        if event.phase == .began && windowController != nil {
            if windowController!.currentScrollMonitor != nil {
                NSEvent.removeMonitor(windowController!.currentScrollMonitor!)
            }
            windowController!.currentScrollMonitor = NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.scrollWheel) { evt in
                self.scrollWheel(with: evt)
                if evt.phase == .ended || evt.phase == .cancelled {
                    NSEvent.removeMonitor(self.windowController!.currentScrollMonitor!)
                    self.windowController!.currentScrollMonitor = nil
                }
                return nil
            }
        }
        
        windowController?.scrolling = event.phase == .began || event.phase == .changed
        windowController?.didScrollSharkle(deltaY: event.deltaY)
    }

    /// If true, Sharkle is currently saying hi.
    var isSaying = false
    /// If true, Sharkle will be drawn inverted.
    var inverted = false {
        didSet {
            imageLayer.compositingFilter = inverted ? CIFilter(name: "CIColorInvert") : nil
        }
    }
    /// Frame number in the current animation.
    var currentFrame = 0
    /// Number of frames until Sharkle stops saying hi.
    var sayTimeout = 0

    /// Updates the animation.
    func update() {
        var frameCount: Int
        var frameName: (Int) -> String
        if isSaying {
            frameCount = SAY_FRAME_COUNT
            frameName = SAY_FRAME
        } else {
            frameCount = IDLE_FRAME_COUNT
            frameName = IDLE_FRAME
        }

        currentFrame += 1
        if currentFrame >= frameCount {
            currentFrame = 0
        }

        if sayTimeout > 0 {
            sayTimeout -= 1
        }

        if sayTimeout == 0 && isSaying {
            isSaying = false
            currentFrame = 0
        }

        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        imageLayer.contents = NSImage(named: frameName(currentFrame))
        CATransaction.commit()

        if let bubbleView = bubbleView {
            bubbleView.isHidden = !isSaying
            if isSaying {
                bubbleView.update()
            }
        }
    }
}
