//
//  SharkleWindowController.swift
//  Sharkle
//
//  Created by cpsdqs on 2020-06-14.
//  Copyright © 2020 cpsdqs. All rights reserved.
//

import Cocoa

/// Sharkle window padding from the screen edge.
let PADDING_RIGHT: CGFloat = 54
let PADDING_BELOW: CGFloat = 26

/// A Sharkle window.
class SharkleWindowController: NSWindowController {

    /// This Sharkle window's designated screen.
    var designatedScreen: NSScreen?

    @IBOutlet weak var bubbleView: BubbleView!
    @IBOutlet weak var sharkleView: SharkleView!

    convenience init(on screen: NSScreen) {
        self.init(windowNibName: "SharkleWindowController")
        showWindow(nil)

        designatedScreen = screen
        updateLocationInScreen()

        updateInverted()

        NotificationCenter.default.addObserver(
            forName: .sharkleConfigChanged,
            object: nil,
            queue: OperationQueue.main
        ) { notif in
            self.updateInverted()
        }
    }

    func updateInverted() {
        self.sharkleView.inverted = UserDefaults.standard.bool(forKey: CFG_DARK)
        self.bubbleView.inverted = self.sharkleView.inverted
    }
    
    var yOffset: CGFloat = 0.0
    var yOffsetVelocity: CGFloat = 0.0
    var displayLink: CVDisplayLink? = nil

    /// Moves Sharkle to the designated screen's corner.
    func updateLocationInScreen() {
        assert(window != nil, "sharkle window should not be nil")
        if let screen = designatedScreen {
            let screenFrame = screen.visibleFrame

            let x = screenFrame.maxX - PADDING_RIGHT - window!.frame.width
            let y = screenFrame.minY + PADDING_BELOW + yOffset

            let rect = NSMakeRect(x, y, window!.frame.width, window!.frame.height)
            window!.setFrame(rect, display: true)
            
            if displayLink == nil {
                var displays: [CGDirectDisplayID] = [0]
                var displayCount: UInt32 = 0
                guard CGGetDisplaysWithPoint(window!.frame.origin, 1, &displays, &displayCount) == .success else { return }
                guard displayCount > 0 else { return }
                let cgDisplay = displays[0]
                guard CVDisplayLinkCreateWithCGDisplay(cgDisplay, &displayLink) == kCVReturnSuccess else { return }
                CVDisplayLinkSetOutputHandler(displayLink!) { _, _, _, _, _  in
                    self.updateAnimation()
                    return kCVReturnSuccess
                }
            }
        } else {
            NSLog("WARNING: sharkle does not have a designated screen!")
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        window!.isOpaque = false
        window!.backgroundColor = .clear
        window!.level = .init(rawValue: -1)
        window!.orderBack(nil)

        sharkleView.bubbleView = bubbleView
        sharkleView.windowController = self
    }
    
    var prevScrollTime: TimeInterval = 0
    var prevDisplayLinkTime: TimeInterval = 0
    var scrolling = false
    var emptyAnimationFrames = 0
    var currentScrollMonitor: Any?
    
    func startDisplayLink() {
        if CVDisplayLinkIsRunning(displayLink!) {
            return
        }
        prevDisplayLinkTime = CACurrentMediaTime()
        CVDisplayLinkStart(displayLink!)
    }

    /// Lets the user scroll on Sharkle to hide the window temporarily.
    func didScrollSharkle(deltaY: CGFloat) {
        guard displayLink != nil else { return }
        
        let deltaTime = max(min(CACurrentMediaTime() - prevScrollTime, 1 / 30), 1 / 999)
        if scrolling && abs(deltaY) > 0.01 {
            let prevYOffset = yOffset
            yOffset -= deltaY * 2 * (yOffset > 0 ? exp(-yOffset / 20) : 1)
            yOffsetVelocity = (yOffset - prevYOffset) / CGFloat(deltaTime)
        }
        prevScrollTime = CACurrentMediaTime()
        emptyAnimationFrames = 0
        
        startDisplayLink()
    }

    func updateAnimation() {
        let deltaTime = CGFloat(CACurrentMediaTime() - prevDisplayLinkTime)
        prevDisplayLinkTime = CACurrentMediaTime()
        let k: CGFloat = yOffset > 0 ? 90 : 6
        let c: CGFloat = yOffset > 0 ? 20 : 9
        
        if !scrolling {
            emptyAnimationFrames = 0
            yOffsetVelocity += (-k * yOffset - c * yOffsetVelocity) * deltaTime
            yOffset += yOffsetVelocity * deltaTime
        } else {
            emptyAnimationFrames += 1
            if emptyAnimationFrames > 100 {
                // the scroll gesture probably glitched and we never received the end event
                scrolling = false
            }
        }

        if !scrolling && abs(yOffset) + abs(yOffsetVelocity) < 0.1 {
            yOffset = 0
            CVDisplayLinkStop(displayLink!)
            debugPrint("scroll animation stopped")
        }

        DispatchQueue.main.async {
            self.updateLocationInScreen()
        }
    }

}
