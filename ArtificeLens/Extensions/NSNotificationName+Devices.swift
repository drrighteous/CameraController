//
//  NSNotificationName+Devices.swift
//  ArtificeLens
//
//

import Foundation

extension NSNotification.Name {
    static let devicesUpdated = NSNotification.Name(rawValue: "DevicesUpdated")
    static let windowOpen = NSNotification.Name(rawValue: "WindowOpen")
    static let windowClose = NSNotification.Name(rawValue: "WindowClose")
    static let captureStillRequested = NSNotification.Name(rawValue: "CaptureStillRequested")
    static let captureStillCompleted = NSNotification.Name(rawValue: "CaptureStillCompleted")
}
