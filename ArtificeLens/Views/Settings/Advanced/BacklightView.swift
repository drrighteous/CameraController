//
//  BacklightView.swift
//  ArtificeLens
//
//

import SwiftUI

struct BacklightView: View {
    @ObservedObject var backlightCompensation: NumberCaptureDeviceProperty

    init(controller: DeviceController) {
        self.backlightCompensation = controller.backlightCompensation
    }

    var body: some View {
        SectionView {
            SectionTitle(title: "Backlight Compensation",
                         image: Image(systemName: "light.beacon.max")) {
                HStack(spacing: 8) {
                    ControlHelpButton(helpText: "Helps compensate when the subject is darker than the background.")
                    Toggle(isOn: backightEnabled)
                }
            }
        }
    }

    var backightEnabled: Binding<Bool> {
        Binding(get: {
            backlightCompensation.sliderValue > 0
        }, set: {
            backlightCompensation.sliderValue = $0 ? backlightCompensation.maximum : 0
        })
    }
}
