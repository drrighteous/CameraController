//
//  PreviewSizeSettings.swift
//  ArtificeLens
//
//

import Foundation

enum PreviewSizeSettings: Double {
    case disabled = 0
    case small = 400
    case medium = 480
    case large = 640
    case extraLarge = 720

    func getHeight() -> Double {
        let videoRatio: Double = 225/400

        return self.rawValue * videoRatio
    }

    func getWidth() -> Double {
        return max(self.rawValue, 400)
    }
}
