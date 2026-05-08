//
//  io_service_t+Interface.swift
//  ArtificeLens
//
//

import Foundation

extension io_service_t {
    func ioCreatePluginInterfaceFor(service: CFUUID,
                                    handle: (PluginInterfacePointer) throws -> Void) rethrows {
        var ref: UnsafeMutablePointer<UnsafeMutablePointer<IOCFPlugInInterface>?>?
        var score: Int32 = 0
        guard IOCreatePlugInInterfaceForService(self, service, kIOCFPlugInInterfaceID,
                                                &ref, &score) == kIOReturnSuccess else { return }
        defer { _ = ref?.pointee?.pointee.Release(ref) }
        guard score == 0 else { return }

        try ref?.withMemoryRebound(to: UnsafeMutablePointer<IOCFPlugInInterface>.self, capacity: 1, handle)
    }
}
