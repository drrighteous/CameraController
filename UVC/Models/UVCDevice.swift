//
//  UCDevice.swift
//  ArtificeLens
//
//

import Foundation
import AVFoundation

typealias USBInterfacePointer = UnsafeMutablePointer<UnsafeMutablePointer<IOUSBInterfaceInterface190>>

public final class UVCDevice {
    let interface: USBInterfacePointer
    public let processingUnitID: Int
    public let cameraTerminalID: Int
    public let properties: UVCDeviceProperties

    public init(device: AVCaptureDevice) throws {
        let deviceInfo = try device.usbDevice()

        interface = deviceInfo.interface
        processingUnitID = deviceInfo.descriptor.processingUnitID
        cameraTerminalID = deviceInfo.descriptor.cameraTerminalID
        properties = UVCDeviceProperties(deviceInfo)
    }

    deinit { _ = interface.pointee.pointee.Release(interface) }
}
