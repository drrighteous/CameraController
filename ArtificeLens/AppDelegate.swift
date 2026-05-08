//
//  AppDelegate.swift
//  ArtificeLens
//
//

import Cocoa
import SwiftUI

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {

    var statusBarManager: StatusBarManager = StatusBarManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        WindowManager.shared.showWindow()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        WindowManager.shared.showWindow()
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
