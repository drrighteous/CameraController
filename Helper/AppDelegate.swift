//
//  AppDelegate.swift
//  Helper
//
//  Created by Itay Brenner on 7/25/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Cocoa
import SwiftUI

enum HelperConstants {
    static let bundleIdentifier = "com.itaysoft.CameraController"
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains {
            $0.bundleIdentifier == HelperConstants.bundleIdentifier
        }

        guard !isRunning else {
            NSApp.terminate(nil)
            return
        }

        var path = Bundle.main.bundlePath as NSString
        for _ in 1...4 {
            path = path.deletingLastPathComponent as NSString
        }

        let configuration = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.openApplication(
            at: URL(fileURLWithPath: path as String),
            configuration: configuration
        ) { _, error in
            if let error {
                NSLog("Unable to open CameraController from login helper: \(error.localizedDescription)")
            }
            NSApp.terminate(nil)
        }
    }
}
