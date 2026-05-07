//
//  IOUSBConfigurationDescriptorPtr+UVC.swift
//  CameraController
//
//  Created by Itay Brenner on 7/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation
import IOKit

extension IOUSBConfigurationDescriptorPtr {
    func proccessDescriptor() -> UVCDescriptor {
        var processingUnitID = -1
        var cameraTerminalID = -1
        var interfaceID = -1

        let remaining = self.pointee.wTotalLength - UInt16(self.pointee.bLength)
        var pointer = UnsafeMutablePointer<UInt8>(OpaquePointer(self))
        pointer = pointer.advanced(by: Int(self.pointee.bLength))

        browseDescriptor(remaining, pointer, &processingUnitID, &cameraTerminalID, &interfaceID)

        return UVCDescriptor(processingUnitID: processingUnitID,
                             cameraTerminalID: cameraTerminalID,
                             interfaceID: interfaceID)
    }

    private func browseDescriptor(_ memory: UInt16, _ pointer: UnsafeMutablePointer<UInt8>,
                                  _ processingUnitID: inout Int,
                                  _ cameraTerminalID: inout Int,
                                  _ interfaceID: inout Int) {
        var remaining = memory
        var currentPointer = pointer

        while remaining > 0 {
            var descriptorPointer = InterfaceDescriptorPointer(OpaquePointer(currentPointer))
            guard let descriptorLength = validDescriptorLength(descriptorPointer, remaining: remaining) else {
                break
            }

            if descriptorPointer.pointee.bDescriptorType == kUSBInterfaceDesc {
                let intDesc = UnsafeMutablePointer<IOUSBInterfaceDescriptor>(OpaquePointer(descriptorPointer))
                if !(intDesc.pointee.bInterfaceClass == UVCConstants.classVideo
                    && intDesc.pointee.bInterfaceSubClass == UVCConstants.subclassVideoControl) {

                    remaining -= UInt16(descriptorLength)
                    currentPointer = currentPointer.advanced(by: descriptorLength)
                    continue
                }

                remaining -= UInt16(descriptorLength)
                currentPointer = currentPointer.advanced(by: descriptorLength)
                descriptorPointer = InterfaceDescriptorPointer(OpaquePointer(currentPointer))
                guard let headerLength = validDescriptorLength(descriptorPointer, remaining: remaining) else {
                    break
                }

                if descriptorPointer.pointee.bDescriptorType != UVCConstants.descriptorTypeInterface {
                    break
                }

                let internalDescriptor = UnsafeMutablePointer<UVC_VCHeaderDescriptor>(OpaquePointer(descriptorPointer))
                if internalDescriptor.pointee.bDescriptorSubType == UVCConstants.subclassVideoControl {
                    let totalLength = UInt16(littleEndian: internalDescriptor.pointee.wTotalLength)
                    guard totalLength >= UInt16(headerLength) else {
                        break
                    }

                    let boundedTotalLength = min(totalLength, remaining)
                    remaining -= boundedTotalLength
                    currentPointer = currentPointer.advanced(by: headerLength)
                    var remainingMemory = boundedTotalLength - UInt16(headerLength)

                    while remainingMemory > 0 {
                        descriptorPointer = InterfaceDescriptorPointer(OpaquePointer(currentPointer))
                        guard let nestedLength = validDescriptorLength(descriptorPointer, remaining: remainingMemory) else {
                            break
                        }

                        if descriptorPointer.pointee.bDescriptorType != UVCConstants.descriptorTypeInterface {
                            break
                        }

                        getDeviceId(descriptorPointer, currentPointer, &processingUnitID, &cameraTerminalID)
                        interfaceID = Int(intDesc.pointee.bInterfaceNumber)

                        if interfaceID != -1 && processingUnitID != -1 && cameraTerminalID != -1 {
                            // Found all necessary data, exit
                            // Fix for WB7022 Camera
                            return
                        }

                        remainingMemory -= UInt16(nestedLength)
                        currentPointer = currentPointer.advanced(by: nestedLength)
                    }
                } else {
                    remaining -= UInt16(headerLength)
                    currentPointer = currentPointer.advanced(by: headerLength)
                }
                break
            } else {
                remaining -= UInt16(descriptorLength)
                currentPointer = currentPointer.advanced(by: descriptorLength)
            }
        }
    }

    private func validDescriptorLength(_ descriptorPointer: InterfaceDescriptorPointer,
                                       remaining: UInt16) -> Int? {
        let descriptorLength = Int(descriptorPointer.pointee.bLength)
        guard descriptorLength > 0, descriptorLength <= Int(remaining) else {
            return nil
        }

        return descriptorLength
    }

    private func getDeviceId(_ descriptorPointer: InterfaceDescriptorPointer,
                             _ currentPointer: UnsafeMutablePointer<UInt8>,
                             _ processingUnitID: inout Int,
                             _ cameraTerminalID: inout Int) {
        let unitType = UVCConstants.DescriptorSubtype(rawValue: descriptorPointer.pointee.bDescriptorSubType)
        switch unitType {
        case .processingUnit:
            let puPointer = ProcessingUnitDescriptorPointer(OpaquePointer(currentPointer))
            processingUnitID = Int(puPointer.pointee.bUnitID)
        case .inputTerminal:
            let ctPointer = CameraTerminalDescriptorPointer(OpaquePointer(currentPointer))
            cameraTerminalID = Int(ctPointer.pointee.bTerminalID)
        case .none:
            break
        case .selectorUnit:
            break
        case .extensionUnit:
            break
        }
    }
}
