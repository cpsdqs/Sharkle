//
//  PreferencesWindowController.swift
//  Sharkle
//
//  Created by cpsdqs on 2020-06-14.
//  Copyright © 2020 cpsdqs. All rights reserved.
//

import Cocoa

let CFG_DARK = "dark"
let CFG_MAIN_ONLY = "mainOnly"

extension Notification.Name {
    static let sharkleConfigChanged = Notification.Name.init(rawValue: "sharkleConfigChanged")
}

class PreferencesWindowController: NSWindowController {
    @IBOutlet weak var darkBackground: NSButton!
    @IBOutlet weak var showOnEveryScreen: NSButton!

    convenience init() {
        self.init(windowNibName: "PreferencesWindowController")
        showWindow(nil)
        window!.level = .popUpMenu
        window!.makeKey()
        window!.orderFront(nil)
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        darkBackground.state = UserDefaults.standard.bool(forKey: CFG_DARK) ? .on : .off
        showOnEveryScreen.state = UserDefaults.standard.bool(forKey: CFG_MAIN_ONLY) ? .off : .on
    }
    
    @IBAction func darkBackgroundDidChange(_ sender: Any) {
        UserDefaults.standard.set(darkBackground.state == .on, forKey: CFG_DARK)
        NotificationCenter.default.post(name: .sharkleConfigChanged, object: nil)
    }

    @IBAction func showOnEveryScreenDidChange(_ sender: Any) {
        UserDefaults.standard.set(showOnEveryScreen.state == .off, forKey: CFG_MAIN_ONLY)
        NotificationCenter.default.post(name: .sharkleConfigChanged, object: nil)
    }
}
