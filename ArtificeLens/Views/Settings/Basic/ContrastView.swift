//
//  ContrastView.swift
//  ArtificeLens
//
//

import SwiftUI

struct ContrastView: View {
    @ObservedObject var contrast: NumberCaptureDeviceProperty

    init(controller: DeviceController) {
        self.contrast = controller.contrast
    }

    var body: some View {
        GenericControl(value: $contrast.sliderValue,
                       step: contrast.resolution,
                       range: contrast.minimum...contrast.maximum,
                       title: "Contrast",
                       imageName: "moonphase.first.quarter",
                       auto: nil,
                       help: "Adjusts separation between dark and light areas in the camera image.")
    }
}
