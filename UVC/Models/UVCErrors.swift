//
//  UVCErrors.swift
//  ArtificeLens
//
//

import Foundation

enum UVCError: Error {
    case requestError
    case invalidUnitId
    case cameraNotFound
    case missingUSBInterface
    case missingConfigurationDescriptor
    case missingUSBConfiguration
}
