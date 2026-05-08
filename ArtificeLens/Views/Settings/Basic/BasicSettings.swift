//
//  BasicSettings.swift
//  ArtificeLens
//
//

import SwiftUI

struct BasicSettings: View {
    @ObservedObject var controller: DeviceController

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Constants.Style.controlsSpacing) {
                if controller.exposureTime.isCapable || controller.irisAbsolute.isCapable || controller.gain.isCapable {
                    ExposureView(controller: controller)
                }

                if controller.brightness.isCapable {
                    BrightnessView(controller: controller)
                }

                if controller.contrast.isCapable {
                    ContrastView(controller: controller)
                }

                if controller.saturation.isCapable {
                    SaturationView(controller: controller)
                }

                if controller.sharpness.isCapable {
                    SharpnessView(controller: controller)
                }

                if controller.gamma.isCapable {
                    GammaView(controller: controller)
                }

                if controller.hue.isCapable && controller.hue.maximum > 0 {
                    HueView(controller: controller)
                }

                if controller.whiteBalance.isCapable {
                    WhiteBalanceView(controller: controller)
                }
            }
            .padding(.top, 2)
            .padding(.bottom, Constants.Style.topSpacing)
        }
        .frame(maxHeight: 300)
    }
}

private struct GammaView: View {
    @ObservedObject var gamma: NumberCaptureDeviceProperty

    init(controller: DeviceController) {
        self.gamma = controller.gamma
    }

    var body: some View {
        GenericControl(value: $gamma.sliderValue,
                       step: gamma.resolution,
                       range: gamma.minimum...gamma.maximum,
                       title: "Gamma",
                       imageName: "circle.lefthalf.filled",
                       auto: nil,
                       help: "Adjusts the camera gamma curve when the device exposes a standard UVC gamma control.")
    }
}
