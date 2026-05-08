//
//  UserSettings.swift
//  ArtificeLens
//
//

import Foundation
import Combine
import ServiceManagement

final class UserSettings: ObservableObject {
    static let shared = UserSettings()

    @Published var openAtLogin: Bool {
        didSet {
            let success = SMLoginItemSetEnabled("com.drrighteous.ArtificeLens.Helper" as CFString, openAtLogin)
            if success {
                UserDefaults.standard.set(openAtLogin, forKey: "login")
            }
        }
    }

    @Published var readRate: RefreshSettingsRate {
        didSet {
            UserDefaults.standard.set(readRate.rawValue, forKey: "readRate")
        }
    }

    @Published var writeRate: RefreshSettingsRate {
        didSet {
            UserDefaults.standard.set(writeRate.rawValue, forKey: "writeRate")
        }
    }

    @Published var lastSelectedDevice: String? {
        didSet {
            UserDefaults.standard.set(lastSelectedDevice, forKey: "lastDevice")
        }
    }

    var hideCameraPreview: Bool {
        cameraPreviewSize == .disabled
    }

    @Published var cameraPreviewSize: PreviewSizeSettings {
        didSet {
            UserDefaults.standard.set(cameraPreviewSize.rawValue, forKey: "cameraPreviewSize")
        }
    }

    @Published var mirrorPreview: Bool {
        didSet {
            UserDefaults.standard.set(mirrorPreview, forKey: "mirrorPreview")
        }
    }

    private init() {
        openAtLogin = UserDefaults.standard.bool(forKey: "login")
        readRate = RefreshSettingsRate(rawValue: UserDefaults.standard.double(forKey: "readRate")) ?? .disabled
        writeRate = RefreshSettingsRate(rawValue: UserDefaults.standard.double(forKey: "writeRate")) ?? .disabled
        lastSelectedDevice = UserDefaults.standard.string(forKey: "lastDevice")
        if let cameraPreviewSizeValue = UserDefaults.standard.object(forKey: "cameraPreviewSize") as? Double {
            cameraPreviewSize = PreviewSizeSettings(rawValue: cameraPreviewSizeValue) ?? .small
        } else {
            cameraPreviewSize = .small
        }
        mirrorPreview = UserDefaults.standard.bool(forKey: "mirrorPreview")
    }
}
