//
//  USBDevice.swift
//  ArtificeLens
//
//

import Foundation
import IOKit.usb

struct USBDevice {
    let interface: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBInterfaceInterface190>>
    let descriptor: UVCDescriptor
}
