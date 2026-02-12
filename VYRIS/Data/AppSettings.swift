import SwiftUI

// MARK: - App Settings
// Persistent user preferences stored in UserDefaults.

@Observable
final class AppSettings {

    var motionEnabled: Bool {
        didSet { UserDefaults.standard.set(motionEnabled, forKey: Keys.motion) }
    }

    var appearanceMode: AppearanceMode {
        didSet { UserDefaults.standard.set(appearanceMode.rawValue, forKey: Keys.appearance) }
    }

    var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.onboarding) }
    }

    var vaultLockEnabled: Bool {
        didSet { UserDefaults.standard.set(vaultLockEnabled, forKey: Keys.vaultLock) }
    }

    init() {
        self.motionEnabled = UserDefaults.standard.object(forKey: Keys.motion) as? Bool ?? true
        let savedAppearance = UserDefaults.standard.string(forKey: Keys.appearance) ?? "system"
        self.appearanceMode = AppearanceMode(rawValue: savedAppearance) ?? .system
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Keys.onboarding)
        self.vaultLockEnabled = UserDefaults.standard.bool(forKey: Keys.vaultLock)
    }

    var colorScheme: ColorScheme? {
        switch appearanceMode {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }

    private enum Keys {
        static let motion = "vyris_motion_enabled"
        static let appearance = "vyris_appearance"
        static let onboarding = "vyris_onboarding_completed"
        static let vaultLock = "vyris_vault_lock"
    }
}

// MARK: - Appearance Mode

enum AppearanceMode: String, CaseIterable, Identifiable {
    case light
    case dark
    case system

    var id: String { rawValue }

    var displayKey: LocalizedStringKey {
        switch self {
        case .light: return "settings.appearanceLight"
        case .dark: return "settings.appearanceDark"
        case .system: return "settings.appearanceSystem"
        }
    }
}

// MARK: - App Version (from Info.plist)

enum AppVersion {
    static var short: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    static var display: String {
        "\(short) (\(build))"
    }
}
