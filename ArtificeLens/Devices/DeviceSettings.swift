//
//  DeviceSettings.swift
//  ArtificeLens
//
//

import Foundation

struct DeviceSettings: Codable {
    let exposureMode: Int
    let exposurePriority: Bool?
    let exposureTime: Float
    let iris: Float?
    let gain: Float
    let brightness: Float
    let contrast: Float
    let saturation: Float
    let sharpness: Float
    let gamma: Float?
    let hueAuto: Bool?
    let hue: Float?
    let whiteBalanceAuto: Bool
    let whiteBalance: Float
    let powerline: Float
    let backlightCompensation: Float
    let zoom: Float
    let pan: Float
    let tilt: Float
    let roll: Float?
    let focusAuto: Bool
    let focus: Float
}
