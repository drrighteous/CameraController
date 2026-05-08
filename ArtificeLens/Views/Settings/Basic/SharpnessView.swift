//
//  SharpnessView.swift
//  ArtificeLens
//
//

import SwiftUI

struct SharpnessView: View {
    @ObservedObject var sharpness: NumberCaptureDeviceProperty

    init(controller: DeviceController) {
        self.sharpness = controller.sharpness
    }

    var body: some View {
        GenericControl(value: $sharpness.sliderValue,
                       step: sharpness.resolution,
                       range: sharpness.minimum...sharpness.maximum,
                       title: "Sharpness",
                       imageName: "triangle.fill",
                       auto: nil,
                       help: "Adjusts the camera's edge enhancement level.")
    }
}
