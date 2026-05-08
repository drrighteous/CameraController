//
//  StatusBarManager.swift
//  ArtificeLens
//
//

import Foundation
import Cocoa

class StatusBarManager {
    var statusBarItem: NSStatusItem!

    init() {
        // Fix for SwiftUI Previews adding Statusbar Items constantly
        #if DEBUG
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            return
        }
        #endif

        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        guard let button = statusBarItem.button else {
            return
        }

        button.image = NSImage(systemSymbolName: "camera.fill",
                               accessibilityDescription: "ArtificeLens")
        button.imageScaling = NSImageScaling.scaleProportionallyDown
        button.target = self
        button.action = #selector(showCustomView)
    }

    @objc
    func showCustomView() {
        guard let button = statusBarItem?.button else {
            return
        }

        WindowManager.shared.toggleShowWindow(from: button)
    }
}
