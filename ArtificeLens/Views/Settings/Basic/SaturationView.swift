//
//  SaturationView.swift
//  ArtificeLens
//
//

import SwiftUI

struct SaturationView: View {
    @ObservedObject var saturation: NumberCaptureDeviceProperty

    init(controller: DeviceController) {
        self.saturation = controller.saturation
    }

    var body: some View {
        GenericControl(value: $saturation.sliderValue,
                       step: saturation.resolution,
                       range: saturation.minimum...saturation.maximum,
                       title: "Saturation",
                       imageName: "eyedropper.halffull",
                       auto: nil,
                       help: "Adjusts color intensity in the camera image.")
    }
}
