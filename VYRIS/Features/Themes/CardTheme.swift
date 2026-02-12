import SwiftUI

// MARK: - Card Theme Protocol

protocol CardThemeDefinition {
    var id: String { get }
    var name: String { get }
    var backgroundColor: Color { get }
    var secondaryBackgroundColor: Color? { get }
    var textColor: Color { get }
    var secondaryTextColor: Color { get }
    var accentColor: Color { get }
    var strokeColor: Color { get }
    var strokeWidth: CGFloat { get }
    var layoutStyle: CardLayoutStyle { get }
    var decorationStyle: DecorationStyle { get }
    var fontStyle: CardFontStyle { get }
    var backgroundStyle: CardBackgroundStyle { get }
}

// MARK: - Card Layout Styles

enum CardLayoutStyle: String, Codable, CaseIterable, Identifiable {
    case classic
    case centered
    case minimal
    case modern
    case editorial
    case split
    case bold
    case stacked
    case executive
    case refined
    case asymmetric
    case monogram
    case photoHero
    case branded
    case socialGrid
    case dualTone
    case magazine
    case techCard
    case profileLeft
    case panoramic

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classic: return "Classic"
        case .centered: return "Centered"
        case .minimal: return "Minimal"
        case .modern: return "Modern"
        case .editorial: return "Editorial"
        case .split: return "Split"
        case .bold: return "Bold"
        case .stacked: return "Stacked"
        case .executive: return "Executive"
        case .refined: return "Refined"
        case .asymmetric: return "Asymmetric"
        case .monogram: return "Monogram"
        case .photoHero: return "Photo Hero"
        case .branded: return "Branded"
        case .socialGrid: return "Social Grid"
        case .dualTone: return "Dual Tone"
        case .magazine: return "Magazine"
        case .techCard: return "Tech"
        case .profileLeft: return "Profile"
        case .panoramic: return "Panoramic"
        }
    }
}

// MARK: - Decoration Styles

enum DecorationStyle: String, Codable, CaseIterable, Identifiable {
    case none
    case cornerLines
    case borderAccent
    case diagonalSlash
    case circuitLines
    case cornerBadge
    case dotGrid
    case concentricCircles
    case geometricFrame
    case accentBar
    case wavePattern
    case diamondGrid

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "None"
        case .cornerLines: return "Corner Lines"
        case .borderAccent: return "Border Accent"
        case .diagonalSlash: return "Diagonal"
        case .circuitLines: return "Circuit"
        case .cornerBadge: return "Badge"
        case .dotGrid: return "Dot Grid"
        case .concentricCircles: return "Circles"
        case .geometricFrame: return "Frame"
        case .accentBar: return "Accent Bar"
        case .wavePattern: return "Wave"
        case .diamondGrid: return "Diamond"
        }
    }
}

// MARK: - Card Font Styles

enum CardFontStyle: String, Codable, CaseIterable, Identifiable {
    case serif
    case sansSerif
    case rounded
    case mono
    case condensed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .serif: return "Serif"
        case .sansSerif: return "Sans Serif"
        case .rounded: return "Rounded"
        case .mono: return "Monospace"
        case .condensed: return "Condensed"
        }
    }

    func nameFont(_ size: CGFloat) -> Font {
        switch self {
        case .serif: return .system(size: size, weight: .regular, design: .serif)
        case .sansSerif: return .system(size: size, weight: .medium, design: .default)
        case .rounded: return .system(size: size, weight: .medium, design: .rounded)
        case .mono: return .system(size: size, weight: .regular, design: .monospaced)
        case .condensed: return .system(size: size, weight: .bold, design: .default)
        }
    }

    func titleFont(_ size: CGFloat) -> Font {
        switch self {
        case .serif: return .system(size: size, weight: .light, design: .serif)
        case .sansSerif: return .system(size: size, weight: .regular, design: .default)
        case .rounded: return .system(size: size, weight: .regular, design: .rounded)
        case .mono: return .system(size: size, weight: .light, design: .monospaced)
        case .condensed: return .system(size: size, weight: .semibold, design: .default)
        }
    }

    func detailFont(_ size: CGFloat) -> Font {
        switch self {
        case .serif: return .system(size: size, weight: .regular, design: .serif)
        case .sansSerif: return .system(size: size, weight: .regular, design: .default)
        case .rounded: return .system(size: size, weight: .regular, design: .rounded)
        case .mono: return .system(size: size, weight: .regular, design: .monospaced)
        case .condensed: return .system(size: size, weight: .medium, design: .default)
        }
    }
}

// MARK: - Card Background Styles

enum CardBackgroundStyle: String, Codable, CaseIterable, Identifiable {
    case solid
    case gradient
    case horizontalGradient
    case diagonalGradient
    case radialGlow
    case dualTone

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .solid: return "Solid"
        case .gradient: return "Gradient"
        case .horizontalGradient: return "H. Gradient"
        case .diagonalGradient: return "Diagonal"
        case .radialGlow: return "Radial Glow"
        case .dualTone: return "Dual Tone"
        }
    }
}

// MARK: - Concrete Theme

struct CardTheme: CardThemeDefinition, Identifiable, Hashable {
    let id: String
    let name: String
    let backgroundColor: Color
    let secondaryBackgroundColor: Color?
    let textColor: Color
    let secondaryTextColor: Color
    let accentColor: Color
    let strokeColor: Color
    let strokeWidth: CGFloat
    let layoutStyle: CardLayoutStyle
    let decorationStyle: DecorationStyle
    let fontStyle: CardFontStyle
    let backgroundStyle: CardBackgroundStyle

    init(
        id: String,
        name: String,
        backgroundColor: Color,
        secondaryBackgroundColor: Color? = nil,
        textColor: Color,
        secondaryTextColor: Color,
        accentColor: Color,
        strokeColor: Color,
        strokeWidth: CGFloat = 0.5,
        layoutStyle: CardLayoutStyle = .classic,
        decorationStyle: DecorationStyle = .none,
        fontStyle: CardFontStyle = .serif,
        backgroundStyle: CardBackgroundStyle = .solid
    ) {
        self.id = id
        self.name = name
        self.backgroundColor = backgroundColor
        self.secondaryBackgroundColor = secondaryBackgroundColor
        self.textColor = textColor
        self.secondaryTextColor = secondaryTextColor
        self.accentColor = accentColor
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.layoutStyle = layoutStyle
        self.decorationStyle = decorationStyle
        self.fontStyle = fontStyle
        self.backgroundStyle = backgroundStyle
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CardTheme, rhs: CardTheme) -> Bool {
        lhs.id == rhs.id
    }

    static func fromCustom(_ data: CustomThemeData, id: String) -> CardTheme {
        CardTheme(
            id: id,
            name: "Custom",
            backgroundColor: Color(hexString: data.backgroundColorHex),
            secondaryBackgroundColor: data.secondaryBackgroundHex.map { Color(hexString: $0) },
            textColor: Color(hexString: data.textColorHex),
            secondaryTextColor: Color(hexString: data.secondaryTextColorHex),
            accentColor: Color(hexString: data.accentColorHex),
            strokeColor: Color(hexString: data.strokeColorHex),
            strokeWidth: CGFloat(data.strokeWidth),
            layoutStyle: CardLayoutStyle(rawValue: data.layoutStyle) ?? .classic,
            decorationStyle: DecorationStyle(rawValue: data.decorationStyle) ?? .none,
            fontStyle: CardFontStyle(rawValue: data.fontStyle) ?? .serif,
            backgroundStyle: CardBackgroundStyle(rawValue: data.backgroundStyle) ?? .solid
        )
    }
}
