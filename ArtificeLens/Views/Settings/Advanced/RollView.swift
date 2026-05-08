//
//  RollView.swift
//  ArtificeLens
//
//

import SwiftUI

struct RollView: View {
    @ObservedObject var rollAbsolute: NumberCaptureDeviceProperty

    init(controller: DeviceController) {
        self.rollAbsolute = controller.rollAbsolute
    }

    var body: some View {
        GenericControl(value: $rollAbsolute.sliderValue,
                       step: rollAbsolute.resolution,
                       range: rollAbsolute.minimum...rollAbsolute.maximum,
                       title: "Roll",
                       imageName: "arrow.counterclockwise",
                       auto: nil,
                       help: "Rotates the image when the camera exposes UVC roll control.")
    }
}
