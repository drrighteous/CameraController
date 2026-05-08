//
//  GenericControl.swift
//  ArtificeLens
//
//

import SwiftUI
import AppKit

struct GenericControl: View {
    @Binding var value: Float
    @Binding var auto: Bool
    @State var step: Float
    @State var range: ClosedRange<Float>

    let title: String
    let imageName: String
    let hasAuto: Bool
    let helpText: String?

    init(value: Binding<Float>,
         step: Float,
         range: ClosedRange<Float>,
         title: String,
         imageName: String,
         auto: Binding<Bool>?,
         help: String? = nil) {
        self._value = value
        self.step = step
        self.range = range
        self.title = title
        self.imageName = imageName
        self.hasAuto = auto != nil
        self._auto = auto ?? .constant(false)
        self.helpText = help
    }

    var body: some View {
        SectionView {
            SectionTitle(title: title,
                         image: image(imageName)) {
                HStack(spacing: 8) {
                    ControlHelpButton(helpText: helpText)

                    if hasAuto,
                       $auto.wrappedValue {
                        AutoBadge()
                            .transition(.opacity)
                    }
                }
            }

            HStack {
                if hasAuto {
                    Toggle(isOn: $auto.animation())
                } else {
                    Toggle(isOn: .constant(false))
                        .hidden()
                }
                ControlSlider(value: $value,
                              step: step,
                              range: range)
                    .disabled($auto.wrappedValue)
            }
        }
    }

    private func image(_ name: String) -> Image {
        if let image = NSImage.init(systemSymbolName: name, accessibilityDescription: nil) {
            return Image(nsImage: image)
        }
        return Image(name)
    }
}

struct ControlHelpButton: View {
    let helpText: String?

    var body: some View {
        if let helpText {
            Image(systemName: "questionmark.circle")
                .foregroundColor(Constants.Colors.regularColor.opacity(0.75))
                .help(helpText)
        }
    }
}

struct ControlSlider: View {
    @Binding var value: Float
    let step: Float
    let range: ClosedRange<Float>

    var body: some View {
        VStack(spacing: 3) {
            Slider(value: $value,
                   step: step,
                   sliderRange: range)

            HStack {
                Text(formatted(range.lowerBound))
                Spacer()
                Text(formatted(value))
                    .fontWeight(.semibold)
                    .monospacedDigit()
                Spacer()
                Text(formatted(range.upperBound))
            }
            .font(.caption2)
            .foregroundColor(Constants.Colors.regularColor.opacity(0.72))
        }
    }

    private func formatted(_ value: Float) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }

        return String(format: "%.1f", value)
    }
}
