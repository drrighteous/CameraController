//
//  AVCaptureDevice+USB.swift
//  CameraController
//
//  Created by Itay Brenner on 7/19/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation
import AVFoundation
import IOKit.usb

extension AVCaptureDevice {

    private func getIOService() throws -> io_service_t {
        var camera: io_service_t = 0
        let cameraInformation = try self.modelID.extractCameraInformation()
        let dictionary: NSMutableDictionary = IOServiceMatching("IOUSBDevice") as NSMutableDictionary
        dictionary["idVendor"] = cameraInformation.vendorId
        dictionary["idProduct"] = cameraInformation.productId

        // adding other keys to this dictionary like kUSBProductString, kUSBVendorString, etc don't
        // seem to have any affect on using IOServiceGetMatchingService to get the correct camera,
        // so we instead get an iterator for the matching services based on idVendor and idProduct
        // and fetch their property dicts and then match against the more specific values

        var iter: io_iterator_t = 0
        if IOServiceGetMatchingServices(kIOMasterPortDefault, dictionary, &iter) == kIOReturnSuccess {
            defer {
                if iter != 0 {
                    IOObjectRelease(iter)
                }
            }

            while true {
                let cameraCandidate = IOIteratorNext(iter)
                guard cameraCandidate != 0 else { break }

                var found = false
                defer {
                    if !found {
                        IOObjectRelease(cameraCandidate)
                    }
                }

                var propsRef: Unmanaged<CFMutableDictionary>?

                if IORegistryEntryCreateCFProperties(
                    cameraCandidate,
                    &propsRef,
                    kCFAllocatorDefault,
                    0) == kIOReturnSuccess {
                    if let properties = propsRef?.takeRetainedValue() {

                        // uniqueID starts with hex version of locationID
                        if let locationID = (properties as NSDictionary)["locationID"] as? Int {
                            let locationIDHex = "0x" + String(locationID, radix: 16)
                            if self.uniqueID.hasPrefix(locationIDHex) {
                                camera = cameraCandidate
                                found = true
                            }
                        }
                        if found {
                            // break out of `while (cameraCandidate != 0)`
                            break
                        }
                    }
                }
            }
        }

        // if we haven't found a camera after looping through the iterator, fallback on GetMatchingService method
        if camera == 0 {
            camera = IOServiceGetMatchingService(kIOMasterPortDefault, dictionary)
        }

        guard camera != 0 else {
            throw UVCError.cameraNotFound
        }

        return camera
    }

    func usbDevice() throws -> USBDevice {

        let camera = try self.getIOService()
        defer {
            IOObjectRelease(camera)
        }
        var interfaceRef: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBInterfaceInterface190>>?
        var configDesc: IOUSBConfigurationDescriptorPtr?
        try camera.ioCreatePluginInterfaceFor(service: kIOUSBDeviceUserClientTypeID) {
            let deviceInterface: DeviceInterfacePointer = try $0.getInterface(uuid: kIOUSBDeviceInterfaceID)
            defer { _ = deviceInterface.pointee.pointee.Release(deviceInterface) }
            let interfaceRequest = IOUSBFindInterfaceRequest(bInterfaceClass: UVCConstants.classVideo,
                                                             bInterfaceSubClass: UVCConstants.subclassVideoControl,
                                                             bInterfaceProtocol: UInt16(kIOUSBFindInterfaceDontCare),
                                                             bAlternateSetting: UInt16(kIOUSBFindInterfaceDontCare))
            try deviceInterface.iterate(interfaceRequest: interfaceRequest) {
                interfaceRef = try $0.getInterface(uuid: kIOUSBInterfaceInterfaceID)
            }

            var returnCode: Int32 = 0
            var numConfig: UInt8 = 0
            returnCode = deviceInterface.pointee.pointee.GetNumberOfConfigurations(deviceInterface, &numConfig)
            guard returnCode == kIOReturnSuccess, numConfig > 0 else {
                throw UVCError.missingUSBConfiguration
            }

            returnCode = deviceInterface.pointee.pointee.GetConfigurationDescriptorPtr(deviceInterface, 0, &configDesc)
            guard returnCode == kIOReturnSuccess else {
                throw UVCError.missingConfigurationDescriptor
            }
        }
        guard let interfaceRef else {
            throw UVCError.missingUSBInterface
        }

        guard let configDesc else {
            throw UVCError.missingConfigurationDescriptor
        }

        let descriptor = configDesc.proccessDescriptor()

        return USBDevice(interface: interfaceRef,
                         descriptor: descriptor)
    }
}
