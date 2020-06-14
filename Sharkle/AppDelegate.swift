//
//  AppDelegate.swift
//  Sharkle
//
//  Created by cpsdqs on 2020-06-14.
//  Copyright © 2020 cpsdqs. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var sharkles: [NSScreen:SharkleWindowController] = [:]

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        syncDisplays()

        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: NSApplication.shared,
            queue: OperationQueue.main) { notif in
                self.syncDisplays()
        }

        NotificationCenter.default.addObserver(
            forName: .sharkleConfigChanged,
            object: nil,
            queue: OperationQueue.main
        ) { notif in
            self.syncDisplays()
        }
    }

    var preferences: PreferencesWindowController?

    @IBAction func showSharklePreferences(_ sender: Any?) {
        if preferences?.window?.isVisible ?? false {
            return
        }
        preferences = PreferencesWindowController()
    }

    func syncDisplays() {
        NSLog("display configuration changed; updating sharkles")

        let mainOnly = UserDefaults.standard.bool(forKey: CFG_MAIN_ONLY)

        let screens = mainOnly ? [NSScreen.screens[0]] : NSScreen.screens

        for screen in screens {
            if sharkles[screen] == nil {
                createSharkle(for: screen)
            }
        }
        for screen in sharkles.keys {
            if !screens.contains(screen) {
                deleteSharkle(for: screen)
            } else {
                sharkles[screen]!.updateLocationInScreen()
            }
        }
    }

    func createSharkle(for screen: NSScreen) {
        NSLog("creating sharkle for screen \(screen.description)")
        let sharkle = SharkleWindowController(on: screen)
        sharkles[screen] = sharkle
    }

    func deleteSharkle(for screen: NSScreen) {
        NSLog("deleting sharkle for screen \(screen.description)")
        if let sharkle = sharkles.removeValue(forKey: screen) {
            sharkle.close()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

