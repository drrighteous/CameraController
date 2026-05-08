//
//  PreviewSection.swift
//  ArtificeLens
//
//

import SwiftUI

struct PreviewSection: View {
    @ObservedObject var settings = UserSettings.shared

    var body: some View {
        SectionView {
            SectionTitle(title: "Preview",
                         image: Image(systemName: "photo"))

            HStack {
                Text("Preview Size")
                Spacer()
                Picker(selection: $settings.cameraPreviewSize, label: Text("")) {
                    Text("Disabled").tag(PreviewSizeSettings.disabled)
                    Text("Small").tag(PreviewSizeSettings.small)
                    Text("Medium").tag(PreviewSizeSettings.medium)
                    Text("Large").tag(PreviewSizeSettings.large)
                    Text("Extra Large").tag(PreviewSizeSettings.extraLarge)
                }
                .frame(width: 200)
            }

            HStack {
                Text("Mirror Preview")
                Spacer()
                Toggle(isOn: $settings.mirrorPreview)
            }
        }
    }
}
