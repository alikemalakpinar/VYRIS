import SwiftUI

// MARK: - VYRIS Color System
// Semantic color tokens for the executive luxury design language.
// All colors support Light and Dark mode automatically.

enum VYRISColors {

    // MARK: - Palette

    static let ivoryBase = Color("IvoryBase")
    static let softInk = Color("SoftInk")
    static let champagneAccent = Color("ChampagneAccent")
    static let warmTaupe = Color("WarmTaupe")
    static let deepSlate = Color("DeepSlate")

    // MARK: - Semantic Tokens

    static var backgroundPrimary: Color {
        Color("BackgroundPrimary")
    }

    static var backgroundSecondary: Color {
        Color("BackgroundSecondary")
    }

    static var textPrimary: Color {
        Color("TextPrimary")
    }

    static var textSecondary: Color {
        Color("TextSecondary")
    }

    static var accent: Color {
        Color("Accent")
    }

    static var stroke: Color {
        Color("Stroke")
    }

    static var shadow: Color {
        Color("Shadow")
    }
}

// MARK: - Programmatic Fallbacks
// Used when asset catalog colors are not yet configured.
// These provide the exact hex values from the spec.

extension VYRISColors {

    enum Resolved {

        // Light mode palette
        static let ivoryBase = Color(hex: 0xF4F1EB)
        static let softInk = Color(hex: 0x1C1C1E)
        static let champagneAccent = Color(hex: 0xC6A96B)
        static let warmTaupe = Color(hex: 0xB9B3A9)
        static let deepSlate = Color(hex: 0x141416)

        // Light mode semantic
        static let backgroundPrimaryLight = Color(hex: 0xF4F1EB)
        static let backgroundSecondaryLight = Color(hex: 0xEDE9E1)
        static let textPrimaryLight = Color(hex: 0x1C1C1E)
        static let textSecondaryLight = Color(hex: 0x6E6E73)
        static let accentLight = Color(hex: 0xC6A96B)
        static let strokeLight = Color(hex: 0xD6D2CB)
        static let shadowLight = Color(hex: 0x1C1C1E).opacity(0.08)

        // Dark mode semantic
        static let backgroundPrimaryDark = Color(hex: 0x141416)
        static let backgroundSecondaryDark = Color(hex: 0x1C1C1E)
        static let textPrimaryDark = Color(hex: 0xF4F1EB)
        static let textSecondaryDark = Color(hex: 0x8E8E93)
        static let accentDark = Color(hex: 0xC6A96B)
        static let strokeDark = Color(hex: 0x2C2C2E)
        static let shadowDark = Color.black.opacity(0.3)
    }
}

// MARK: - Adaptive Color Helper

extension VYRISColors {

    static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}

// MARK: - Resolved Semantic Tokens (Adaptive)

extension VYRISColors {

    enum Semantic {
        static let backgroundPrimary = adaptive(
            light: Resolved.backgroundPrimaryLight,
            dark: Resolved.backgroundPrimaryDark
        )
        static let backgroundSecondary = adaptive(
            light: Resolved.backgroundSecondaryLight,
            dark: Resolved.backgroundSecondaryDark
        )
        static let textPrimary = adaptive(
            light: Resolved.textPrimaryLight,
            dark: Resolved.textPrimaryDark
        )
        static let textSecondary = adaptive(
            light: Resolved.textSecondaryLight,
            dark: Resolved.textSecondaryDark
        )
        static let accent = adaptive(
            light: Resolved.accentLight,
            dark: Resolved.accentDark
        )
        static let stroke = adaptive(
            light: Resolved.strokeLight,
            dark: Resolved.strokeDark
        )
        static let shadow = adaptive(
            light: Color(hex: 0x1C1C1E).opacity(0.08),
            dark: Color.black.opacity(0.3)
        )
    }

    private static func adaptive(light: Color, dark: Color) -> Color {
        // Disambiguation — calls the enum-level function
        VYRISColors.adaptive(light: light, dark: dark)
    }
}

// MARK: - Color Picker Swatches (Single Source of Truth)
// Derived from VYRISColors resolved palette + ThemeRegistry accent colors.
// No hardcoded hex values outside this file.

enum VYRISColorSwatches {
    static let all: [Color] = [
        // Core design system palette
        VYRISColors.Resolved.ivoryBase,
        VYRISColors.Resolved.softInk,
        VYRISColors.Resolved.champagneAccent,
        VYRISColors.Resolved.warmTaupe,
        VYRISColors.Resolved.deepSlate,
        // Semantic tokens (light mode resolved)
        VYRISColors.Resolved.backgroundPrimaryLight,
        VYRISColors.Resolved.backgroundSecondaryLight,
        VYRISColors.Resolved.textPrimaryLight,
        VYRISColors.Resolved.textSecondaryLight,
        VYRISColors.Resolved.strokeLight,
        // Theme accent colors (from ThemeRegistry)
        ThemeRegistry.midnightGold.accentColor,
        ThemeRegistry.neonMint.accentColor,
        ThemeRegistry.coralSunset.accentColor,
        ThemeRegistry.navyExecutive.accentColor,
        ThemeRegistry.arcticMinimal.accentColor,
        ThemeRegistry.electricViolet.accentColor,
        ThemeRegistry.forestCorporate.accentColor,
        ThemeRegistry.warmTerracotta.accentColor,
        ThemeRegistry.tokyoNeon.accentColor,
        ThemeRegistry.swissDesign.accentColor,
        ThemeRegistry.roseGold.accentColor,
        // Essentials
        .white,
        .black,
        ThemeRegistry.warmTerracotta.backgroundColor,
    ]
}
