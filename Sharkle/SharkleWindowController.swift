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

    /// Moves Sharkle to the designated screen's corner.
    func updateLocationInScreen() {
        assert(window != nil, "sharkle window should not be nil")
        if let screen = designatedScreen {
            let screenFrame = screen.visibleFrame

            let x = screenFrame.maxX - PADDING_RIGHT - window!.frame.width
            let y = screenFrame.minY + PADDING_BELOW

            let rect = NSMakeRect(x, y, window!.frame.width, window!.frame.height)
            window!.setFrame(rect, display: true)
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
    }

}
