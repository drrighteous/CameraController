//
//  Typealiases.swift
//  UVC
//
//

import Foundation

typealias DeviceInterfacePointer = UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>>
typealias PluginInterfacePointer = UnsafeMutablePointer<UnsafeMutablePointer<IOCFPlugInInterface>>
typealias InterfaceDescriptorPointer = UnsafeMutablePointer<UVC_InterfaceDescriptorHdr>
typealias ProcessingUnitDescriptorPointer = UnsafeMutablePointer<UVC_ProcessingUnitDescriptor>
typealias CameraTerminalDescriptorPointer = UnsafeMutablePointer<UVC_CameraTerminalDescriptor>
