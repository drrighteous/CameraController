//
//  ExposureView.swift
//  ArtificeLens
//
//

import SwiftUI
import UVC

struct ExposureView: View {
    @ObservedObject var exposureMode: BitmapCaptureDeviceProperty
    @ObservedObject var exposurePriority: BoolCaptureDeviceProperty
    @ObservedObject var exposureTime: NumberCaptureDeviceProperty
    @ObservedObject var iris: NumberCaptureDeviceProperty
    @ObservedObject var gain: NumberCaptureDeviceProperty

    private var isAutoControlled: Bool {
        exposureMode.selected != .manual
    }

    private var canEditExposureTime: Bool {
        exposureMode.selected == .manual || exposureMode.selected == .shutterPriority
    }

    private var canEditIris: Bool {
        exposureMode.selected == .manual || exposureMode.selected == .aperturePriority
    }

    private var canEditGain: Bool {
        exposureMode.selected == .manual
    }

    init(controller: DeviceController) {
        self.exposureTime = controller.exposureTime
        self.exposureMode = controller.exposureMode
        self.exposurePriority = controller.exposurePriority
        self.iris = controller.irisAbsolute
        self.gain = controller.gain
    }

    var body: some View {
        SectionView {
            SectionTitle(title: "Exposure",
                         image: Image(systemName: "clock.fill")) {
                HStack(spacing: 8) {
                    ControlHelpButton(helpText: "Controls UVC exposure mode, exposure time, iris, gain, and frame-rate priority when the camera supports them.")

                    if isAutoControlled {
                        AutoBadge()
                            .transition(.opacity)
                    }
                }
            }

            if exposureMode.isCapable {
                Picker("Mode", selection: $exposureMode.selected.animation()) {
                    ForEach(UVCBitmapControl.BitmapValue.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .help(exposureMode.selected.helpText)
            }

            if exposureTime.isCapable {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text("Exposure Time")
                            .fontWeight(.heavy)
                        ControlHelpButton(helpText: "Manual and shutter-priority modes let you set exposure time directly.")
                        Spacer()
                    }

                    HStack {
                        Toggle(isOn: .constant(canEditExposureTime))
                            .disabled(true)
                        ControlSlider(value: $exposureTime.sliderValue,
                                      step: exposureTime.resolution,
                                      range: exposureTime.minimum...exposureTime.maximum)
                            .disabled(!canEditExposureTime)
                    }
                }
            }

            if iris.isCapable {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text("Iris")
                            .fontWeight(.heavy)
                        ControlHelpButton(helpText: "Manual and iris-priority modes let you set the camera iris directly when exposed by UVC.")
                        Spacer()
                    }

                    HStack {
                        Toggle(isOn: .constant(canEditIris))
                            .disabled(true)
                        ControlSlider(value: $iris.sliderValue,
                                      step: iris.resolution,
                                      range: iris.minimum...iris.maximum)
                            .disabled(!canEditIris)
                    }
                }
            }

            if exposurePriority.isCapable {
                HStack {
                    Toggle(isOn: $exposurePriority.isEnabled.animation())
                        .disabled(!isAutoControlled)

                    HStack(spacing: 8) {
                        Text("Auto Exposure Priority")
                            .fontWeight(.heavy)
                        ControlHelpButton(helpText: "Allows the camera to vary frame rate to preserve auto exposure in difficult lighting.")
                        Spacer()
                    }
                }
            }

            if gain.isCapable {
                HStack {
                    Toggle(isOn: .constant(canEditGain))
                        .disabled(true)
                    VStack {
                        HStack {
                            Text("Gain")
                                .fontWeight(.heavy)
                            ControlHelpButton(helpText: "Raises sensor gain in manual exposure mode. Higher gain can brighten the image with more noise.")
                            Spacer()
                        }
                        HStack {
                            ControlSlider(value: $gain.sliderValue,
                                          step: gain.resolution,
                                          range: gain.minimum...gain.maximum)
                            .disabled(!canEditGain)
                        }
                    }
                }
            }
        }
    }
}
