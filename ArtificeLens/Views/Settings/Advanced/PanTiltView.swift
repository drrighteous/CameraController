//
//  PanTiltView.swift
//  ArtificeLens
//
//

import SwiftUI

struct PanTiltView: View {
    @ObservedObject var panTiltAbsolute: MultipleCaptureDeviceProperty

    init(controller: DeviceController) {
        self.panTiltAbsolute = controller.panTiltAbsolute
    }

    var body: some View {
        VStack(spacing: Constants.Style.controlsSpacing) {
            SectionView {
                SectionTitle(title: "Pan",
                             image: Image(systemName: "arrow.left.and.right")) {
                    ControlHelpButton(helpText: "Moves the zoomed image horizontally when digital pan is available.")
                }
                HStack {
                    Toggle(isOn: .constant(false))
                        .hidden()
                    ControlSlider(value: $panTiltAbsolute.sliderValue1,
                                  step: panTiltAbsolute.resolution1,
                                  range: panTiltAbsolute.minimum1...panTiltAbsolute.maximum1)
                }
            }

            SectionView {
                SectionTitle(title: "Tilt",
                             image: Image(systemName: "arrow.up.and.down")) {
                    ControlHelpButton(helpText: "Moves the zoomed image vertically when digital tilt is available.")
                }
                HStack {
                    Toggle(isOn: .constant(false))
                        .hidden()
                    ControlSlider(value: $panTiltAbsolute.sliderValue2,
                                  step: panTiltAbsolute.resolution2,
                                  range: panTiltAbsolute.minimum2...panTiltAbsolute.maximum2)
                }
            }
        }
    }
}
