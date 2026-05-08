//
//  BrightnessView.swift
//  ArtificeLens
//
//

import SwiftUI

struct BrightnessView: View {
    @ObservedObject var brightness: NumberCaptureDeviceProperty

    init(controller: DeviceController) {
        self.brightness = controller.brightness
    }

    var body: some View {
        GenericControl(value: $brightness.sliderValue,
                       step: brightness.resolution,
                       range: brightness.minimum...brightness.maximum,
                       title: "Brightness",
                       imageName: "sun.max.fill",
                       auto: nil,
                       help: "Adjusts the camera image brightness within the range reported by the device.")
    }
}
