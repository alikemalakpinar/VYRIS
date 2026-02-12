import SwiftUI

// MARK: - Supported Languages

enum AppLanguage: String, CaseIterable, Identifiable {
    case auto = "auto"
    case english = "en"
    case turkish = "tr"
    case arabic = "ar"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .auto: return NSLocalizedString("settings.languageAuto", comment: "")
        case .english: return "English"
        case .turkish: return "Türkçe"
        case .arabic: return "العربية"
        }
    }

    var isRTL: Bool {
        self == .arabic
    }

    var locale: Locale {
        switch self {
        case .auto: return .current
        case .english: return Locale(identifier: "en")
        case .turkish: return Locale(identifier: "tr")
        case .arabic: return Locale(identifier: "ar")
        }
    }

    var layoutDirection: LayoutDirection {
        isRTL ? .rightToLeft : .leftToRight
    }
}

// MARK: - Localization Manager

@Observable
final class LocalizationManager {
    var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "vyris_language")
            applyLanguage()
        }
    }

    var layoutDirection: LayoutDirection {
        effectiveLanguage.layoutDirection
    }

    var effectiveLanguage: AppLanguage {
        if currentLanguage == .auto {
            let preferred = Locale.preferredLanguages.first ?? "en"
            if preferred.starts(with: "ar") { return .arabic }
            if preferred.starts(with: "tr") { return .turkish }
            return .english
        }
        return currentLanguage
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: "vyris_language") ?? "auto"
        self.currentLanguage = AppLanguage(rawValue: saved) ?? .auto
    }

    private func applyLanguage() {
        let lang = effectiveLanguage
        if lang.isRTL {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
    }
}
