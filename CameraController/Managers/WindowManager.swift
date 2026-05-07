//
//  WindowManager.swift
//  CameraController
//
//  Created by Itay Brenner on 25/1/22.
//  Copyright © 2022 Itaysoft. All rights reserved.
//

import Foundation
import AppKit
import SwiftUI

class WindowManager: NSObject {
    static let shared = WindowManager()

    private var window: NSWindow?
    private var isShowing: Bool = false

    func toggleShowWindow(from button: NSButton) {
        if isShowing {
            closeWindow()
        } else {
            showWindow(from: button)
        }
    }

    func showWindow(from button: NSButton? = nil) {
        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApplication.shared.activate(ignoringOtherApps: true)
            isShowing = true
            return
        }

        NotificationCenter.default.post(name: .windowOpen, object: nil)

        let contentView = ContentView()

        let hostingController = NSHostingController(rootView: contentView)
        let newWindow = NSWindow(contentViewController: hostingController)
        newWindow.title = "CameraController"
        newWindow.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        newWindow.isReleasedWhenClosed = false
        newWindow.delegate = self
        newWindow.minSize = NSSize(width: 320, height: 480)
        newWindow.setContentSize(NSSize(
            width: UserSettings.shared.cameraPreviewSize.getWidth(),
            height: 650
        ))

        window = newWindow
        DispatchQueue.main.async { [weak self] in
            self?.window?.center()
            self?.window?.makeKeyAndOrderFront(nil)
            NSApplication.shared.activate(ignoringOtherApps: true)
        }

        isShowing = true
    }

    func closeWindow() {
        window?.performClose(nil)
    }
}

extension WindowManager: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        NotificationCenter.default.post(name: .windowClose, object: nil)
        isShowing = false
        window = nil
    }
}
