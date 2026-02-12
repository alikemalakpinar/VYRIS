import SwiftUI

// MARK: - VYRIS Typography System
// Two font families: System (SF) for UI, Serif (New York) for card identity.
// All styles support Dynamic Type.

enum VYRISTypography {

    // MARK: - UI Fonts (SF Pro)

    static func displayLarge(weight: Font.Weight = .light) -> Font {
        .system(size: 34, weight: weight, design: .default)
    }

    static func title(weight: Font.Weight = .medium) -> Font {
        .system(size: 22, weight: weight, design: .default)
    }

    static func body(weight: Font.Weight = .regular) -> Font {
        .system(size: 17, weight: weight, design: .default)
    }

    static func meta(weight: Font.Weight = .regular) -> Font {
        .system(size: 13, weight: weight, design: .default)
    }

    static func button(weight: Font.Weight = .semibold) -> Font {
        .system(size: 15, weight: weight, design: .default)
    }

    static func caption(weight: Font.Weight = .regular) -> Font {
        .system(size: 11, weight: weight, design: .default)
    }

    // MARK: - Card Fonts (Serif — New York)

    static func cardName(size: CGFloat = 22) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }

    static func cardTitle(size: CGFloat = 14) -> Font {
        .system(size: size, weight: .light, design: .serif)
    }

    static func cardDetail(size: CGFloat = 12) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }

    static func cardCompany(size: CGFloat = 13) -> Font {
        .system(size: size, weight: .medium, design: .serif)
    }

    // MARK: - Branding

    static func brandMark(size: CGFloat = 18) -> Font {
        .system(size: size, weight: .light, design: .serif)
    }
}

// MARK: - View Modifier for Typography Tokens

struct VYRISTextStyle: ViewModifier {
    let font: Font
    let color: Color
    let tracking: CGFloat

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
            .tracking(tracking)
    }
}

extension View {

    func vyrisTextStyle(
        _ font: Font,
        color: Color = VYRISColors.Semantic.textPrimary,
        tracking: CGFloat = 0
    ) -> some View {
        modifier(VYRISTextStyle(font: font, color: color, tracking: tracking))
    }
}
