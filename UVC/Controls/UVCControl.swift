//
//  UVCControl.swift
//  ArtificeLens
//
//

import Foundation

protocol Selector {
    func raw() -> Int
}

public enum UVCControlUnit: String, Codable {
    case cameraTerminal
    case processingUnit
}

public struct UVCControlMetadata: Codable {
    public let key: String
    public let name: String
    public let unit: UVCControlUnit
    public let selector: Int
    public let size: Int
    public let isSigned: Bool
    public let isRelative: Bool
    public let hasMinimum: Bool
    public let hasMaximum: Bool
    public let hasDefault: Bool
    public let hasResolution: Bool

    init(key: String,
         name: String,
         unit: UVCControlUnit,
         selector: Selector,
         size: Int,
         isSigned: Bool = false,
         isRelative: Bool = false,
         hasMinimum: Bool = false,
         hasMaximum: Bool = false,
         hasDefault: Bool = true,
         hasResolution: Bool = false) {
        self.key = key
        self.name = name
        self.unit = unit
        self.selector = selector.raw()
        self.size = size
        self.isSigned = isSigned
        self.isRelative = isRelative
        self.hasMinimum = hasMinimum
        self.hasMaximum = hasMaximum
        self.hasDefault = hasDefault
        self.hasResolution = hasResolution
    }
}

public struct UVCControlCapabilities: Codable {
    public let rawValue: Int
    public let canGet: Bool
    public let canSet: Bool
    public let disabledByAutoMode: Bool
    public let supportsAsyncUpdates: Bool

    init(rawValue: Int = 0) {
        self.rawValue = rawValue
        self.canGet = rawValue & 0x01 != 0
        self.canSet = rawValue & 0x02 != 0
        self.disabledByAutoMode = rawValue & 0x04 != 0
        self.supportsAsyncUpdates = rawValue & 0x08 != 0
    }
}

public struct UVCControlDiagnostic: Codable {
    public let key: String
    public let name: String
    public let unit: String
    public let selector: Int
    public let size: Int
    public let signed: Bool
    public let relative: Bool
    public let supported: Bool
    public let canGet: Bool
    public let canSet: Bool
    public let rawInfo: Int
    public let lastError: String?
    public let current: Int?
    public let minimum: Int?
    public let maximum: Int?
    public let defaultValue: Int?
    public let resolution: Int?
}

public class UVCControl {
    let interface: USBInterfacePointer
    let uvcSize: Int
    let uvcSelector: Int
    let uvcUnit: Int
    let uvcInterface: Int

    public let metadata: UVCControlMetadata
    public var isCapable: Bool = false
    public private(set) var capabilities = UVCControlCapabilities()
    public private(set) var lastErrorDescription: String?

    init(_ interface: USBInterfacePointer, _ uvcSize: Int, _ uvcSelector: Selector,
         _ uvcUnit: Int, _ uvcInterface: Int, metadata: UVCControlMetadata? = nil) {
        self.interface = interface
        self.uvcSize = uvcSize
        self.uvcSelector = uvcSelector.raw()
        self.uvcUnit = uvcUnit
        self.uvcInterface = uvcInterface
        self.metadata = metadata ?? UVCControlMetadata(key: "selector-\(uvcSelector.raw())",
                                                       name: "Selector \(uvcSelector.raw())",
                                                       unit: .cameraTerminal,
                                                       selector: uvcSelector,
                                                       size: uvcSize)
    }

    func getDataFor(type: UVCRequestCodes, length: Int) -> Int {
        let requestType = USBmakebmRequestType(direction: kUSBIn, type: kUSBClass, recipient: kUSBInterface)

        do {
            let value = try performRequest(type: type,
                                           length: length,
                                           requestType: requestType)
            lastErrorDescription = nil
            return decodedValue(value, requestType: type, length: length)
        } catch {
            lastErrorDescription = error.localizedDescription
            // Should not return 0, but working on improving this
            return 0
        }
    }

    func setData(value: Int, length: Int) -> Bool {
        let requestType = USBmakebmRequestType(direction: kUSBOut, type: kUSBClass, recipient: kUSBInterface)

        do {
            _ = try performRequest(type: UVCRequestCodes.setCurrent,
                                   length: length,
                                   requestType: requestType,
                                   value: value)
            lastErrorDescription = nil
            return true
        } catch {
            lastErrorDescription = error.localizedDescription
            return false
        }
    }

    func updateIsCapable() {
        capabilities = UVCControlCapabilities(rawValue: getDataFor(type: UVCRequestCodes.getInfo, length: 1))
        isCapable = capabilities.canGet && capabilities.canSet
    }

    public func diagnosticReport() -> UVCControlDiagnostic {
        UVCControlDiagnostic(key: metadata.key,
                             name: metadata.name,
                             unit: metadata.unit.rawValue,
                             selector: metadata.selector,
                             size: metadata.size,
                             signed: metadata.isSigned,
                             relative: metadata.isRelative,
                             supported: isCapable,
                             canGet: capabilities.canGet,
                             canSet: capabilities.canSet,
                             rawInfo: capabilities.rawValue,
                             lastError: lastErrorDescription,
                             current: nil,
                             minimum: nil,
                             maximum: nil,
                             defaultValue: nil,
                             resolution: nil)
    }

    private func performRequest(type: UVCRequestCodes,
                                length: Int,
                                requestType: UInt8,
                                value: Int = 0) throws -> Int {
        guard uvcUnit >= 0 else {
            throw UVCError.invalidUnitId
        }

        var value = value

        try withUnsafeMutablePointer(to: &value, { value in
            var request = IOUSBDevRequest(bmRequestType: requestType,
                                          bRequest: UInt8(type.rawValue),
                                          wValue: UInt16(uvcSelector<<8),
                                          wIndex: UInt16(uvcUnit<<8) | UInt16(uvcInterface),
                                          wLength: UInt16(length),
                                          pData: value,
                                          wLenDone: 0)
            if #available(macOS 12.0, *) {
                guard
                    interface.pointee.pointee.ControlRequest(interface, 0, &request) == kIOReturnSuccess else {
                    throw UVCError.requestError
                }
            } else {
                guard interface.pointee.pointee.USBInterfaceOpenSeize(interface) == kIOReturnSuccess else {
                    throw UVCError.requestError
                }

                defer {
                    _ = interface.pointee.pointee.USBInterfaceClose(interface)
                }

                guard interface.pointee.pointee.ControlRequest(interface, 0, &request) == kIOReturnSuccess else {
                    throw UVCError.requestError
                }
            }
        })
        return value
    }

    private func decodedValue(_ value: Int, requestType: UVCRequestCodes, length: Int) -> Int {
        guard metadata.isSigned,
              requestType != .getInfo,
              length > 0,
              length < MemoryLayout<Int>.size else {
            return value
        }

        let bitWidth = length * 8
        let mask = (1 << bitWidth) - 1
        let signBit = 1 << (bitWidth - 1)
        let unsignedValue = value & mask

        if unsignedValue & signBit != 0 {
            return unsignedValue - (1 << bitWidth)
        }

        return unsignedValue
    }

    private func USBmakebmRequestType(direction: Int, type: Int, recipient: Int) -> UInt8 {
        return UInt8((direction & kUSBRqDirnMask) << kUSBRqDirnShift) |
            UInt8((type & kUSBRqTypeMask) << kUSBRqTypeShift)|UInt8(recipient & kUSBRqRecipientMask)

    }
}
