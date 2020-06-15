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

    /// List of sharkles and their designated screen.
    var sharkles: [NSScreen:SharkleWindowController] = [:]

    func applicationDidFinishLaunching(_ aNotification: Notification) {
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

    /// Current preferences controller instance. May have been closed.
    var preferences: PreferencesWindowController?

    /// Shows Sharkle preferences. Does nothing if preferences are already open.
    @IBAction func showSharklePreferences(_ sender: Any?) {
        if preferences?.window?.isVisible ?? false {
            return
        }
        preferences = PreferencesWindowController()
    }

    /// Synchronizes Sharkles with the current display configuration.
    func syncDisplays() {
        NSLog("display configuration changed; updating sharkles")

        let mainOnly = UserDefaults.standard.bool(forKey: CFG_MAIN_ONLY)

        let screens = mainOnly
            ? (NSScreen.screens.isEmpty ? [] : [NSScreen.screens[0]])
            : NSScreen.screens

        for screen in screens {
            if sharkles[screen] == nil {
                createSharkle(for: screen)
            } else {
                // copy screen data again
                sharkles[screen]!.designatedScreen = screen
                sharkles[screen]!.updateLocationInScreen()
            }
        }
        for screen in sharkles.keys {
            if !screens.contains(screen) {
                deleteSharkle(for: screen)
            }
        }
    }

    /// Creates a Sharkle for the given screen.
    func createSharkle(for screen: NSScreen) {
        if #available(OSX 10.15, *) {
            NSLog("creating sharkle for screen \(screen.localizedName)")
        } else {
            NSLog("creating sharkle for screen \(screen.description)")
        }
        let sharkle = SharkleWindowController(on: screen)
        sharkles[screen] = sharkle
    }

    /// Deletes the Sharkle that corresponds to the given screen.
    func deleteSharkle(for screen: NSScreen) {
        if #available(OSX 10.15, *) {
            NSLog("deleting sharkle for screen \(screen.localizedName)")
        } else {
            NSLog("deleting sharkle for screen \(screen.description)")
        }
        if let sharkle = sharkles.removeValue(forKey: screen) {
            sharkle.close()
        }
    }

}

