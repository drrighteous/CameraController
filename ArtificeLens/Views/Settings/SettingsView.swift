//
//  SettingsView.swift
//  ArtificeLens
//
//

import SwiftUI
import AppKit
import UVC
import UniformTypeIdentifiers

struct SettingsView: View {
    @Binding var captureDevice: CaptureDevice?
    @Binding var currentSection: Int?

    var body: some View {
        contentView()
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Constants.Style.padding)
            .padding(.bottom, Constants.Style.padding)
            .transition(.opacity.animation(.easeOut(duration: 0.25)))
            .id(currentSection)
    }

    @ViewBuilder
    private func contentView() -> some View {
        if currentSection == nil {
            EmptyView()
        } else if currentSection == 3 {
            PreferencesView()
        } else if currentSection == 4, let device = captureDevice {
            DiagnosticsView(captureDevice: device)
        } else if let controller = captureDevice?.controller {
            if currentSection == 0 {
                BasicSettings(controller: controller)
            } else if currentSection == 1 {
                AdvancedView(controller: controller)
            } else if currentSection == 2 {
                ProfilesView()
            }
        } else {
            UnsupportedView()
        }
    }
}

private struct DiagnosticsView: View {
    let captureDevice: CaptureDevice
    @State private var exportMessage: String?

    private var report: CameraDiagnosticsReport {
        captureDevice.diagnosticsReport()
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Constants.Style.controlsSpacing) {
                summarySection
                formatSection
                controlsSection
            }
            .padding(.top, 2)
            .padding(.bottom, Constants.Style.topSpacing)
        }
        .frame(maxHeight: 300)
    }

    private var summarySection: some View {
        let currentReport = report
        return SectionView {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentReport.deviceName)
                        .fontWeight(.heavy)
                    diagnosticLine("Model", currentReport.modelID)
                    diagnosticLine("Camera Terminal", currentReport.cameraTerminalID.map(String.init))
                    diagnosticLine("Processing Unit", currentReport.processingUnitID.map(String.init))
                }

                Spacer()

                HStack(spacing: 10) {
                    Button {
                        DevicesManager.shared.refreshDevices()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.borderless)
                    .help("Refresh connected cameras.")

                    Button {
                        exportDiagnostics()
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                    .buttonStyle(.borderless)
                    .help("Export a local JSON diagnostics report.")
                }
            }

            if let exportMessage {
                Text(exportMessage)
                    .font(.caption)
                    .foregroundColor(Constants.Colors.regularColor.opacity(0.72))
            }
        }
    }

    @ViewBuilder
    private var formatSection: some View {
        if let format = report.activeFormat {
            SectionView {
                HStack {
                    Text("Active Format")
                        .fontWeight(.heavy)
                    Spacer()
                    Text("\(format.width)x\(format.height) \(format.mediaSubType)")
                        .monospacedDigit()
                }

                if let minFrameRate = format.activeMinFrameRate,
                   let maxFrameRate = format.activeMaxFrameRate {
                    diagnosticLine("Active FPS", "\(formatted(minFrameRate))-\(formatted(maxFrameRate))")
                }

                if let range = format.supportedFrameRateRanges.first {
                    diagnosticLine("Supported FPS", "\(formatted(range.minFrameRate))-\(formatted(range.maxFrameRate))")
                }
            }
        }
    }

    private var controlsSection: some View {
        let controls = report.controls
        let supportedCount = controls.filter(\.supported).count

        return SectionView {
            HStack {
                Text("UVC Controls")
                    .fontWeight(.heavy)
                Spacer()
                Text("\(supportedCount)/\(controls.count)")
                    .font(.caption)
                    .monospacedDigit()
            }

            ForEach(controls, id: \.key) { control in
                DiagnosticControlRow(control: control)
            }
        }
    }

    private func diagnosticLine(_ label: String, _ value: String?) -> some View {
        HStack {
            Text(label)
                .foregroundColor(Constants.Colors.regularColor.opacity(0.72))
            Spacer()
            Text(value ?? "Unavailable")
                .multilineTextAlignment(.trailing)
                .monospacedDigit()
        }
        .font(.caption)
    }

    private func exportDiagnostics() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = "\(safeFileName(captureDevice.name))-diagnostics.json"

        panel.begin { response in
            guard response == .OK, let url = panel.url else {
                return
            }

            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                encoder.dateEncodingStrategy = .iso8601
                let data = try encoder.encode(captureDevice.diagnosticsReport())
                let accessed = url.startAccessingSecurityScopedResource()
                defer {
                    if accessed {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                try data.write(to: url, options: .atomic)
                exportMessage = "Saved \(url.lastPathComponent)"
            } catch {
                exportMessage = "Export failed: \(error.localizedDescription)"
            }
        }
    }

    private func safeFileName(_ value: String) -> String {
        value
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
    }

    private func formatted(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }

        return String(format: "%.2f", value)
    }
}

private struct DiagnosticControlRow: View {
    let control: UVCControlDiagnostic

    var body: some View {
        VStack(spacing: 3) {
            HStack {
                Text(control.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                Text(status)
                    .font(.caption2)
                    .foregroundColor(statusColor)
            }

            HStack {
                Text("0x\(String(control.selector, radix: 16).uppercased())")
                Spacer()
                Text(valueSummary)
            }
            .font(.caption2)
            .foregroundColor(Constants.Colors.regularColor.opacity(0.62))
            .monospacedDigit()
        }
        .padding(.vertical, 2)
    }

    private var status: String {
        if control.lastError != nil {
            return "Error"
        }

        if control.supported {
            return "RW"
        }

        if control.canGet {
            return "Read"
        }

        return "Off"
    }

    private var statusColor: Color {
        if control.lastError != nil {
            return .red.opacity(0.85)
        }

        return control.supported ? Constants.Colors.accentColor : Constants.Colors.regularColor.opacity(0.5)
    }

    private var valueSummary: String {
        if let lastError = control.lastError {
            return lastError
        }

        let current = control.current.map(String.init) ?? "-"
        let range: String
        if let minimum = control.minimum, let maximum = control.maximum {
            range = " \(minimum)-\(maximum)"
        } else {
            range = ""
        }
        return "cur \(current)\(range)"
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(
            captureDevice: .constant(nil),
            currentSection: .constant(nil)
        )
    }
}
#endif
