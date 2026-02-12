import SwiftUI

// MARK: - Theme Registry
// 12 Executive Luxury themes built on the Ivory system.

enum ThemeRegistry {

    static let allThemes: [CardTheme] = [
        ivoryClassic,
        midnightGold,
        slateSilver,
        champagneDream,
        obsidianEdge,
        porcelain,
        espresso,
        arcticFrost,
        venetianNight,
        sandstone,
        carbonFiber,
        roseGold
    ]

    static func theme(for id: String) -> CardTheme {
        allThemes.first(where: { $0.id == id }) ?? ivoryClassic
    }

    // MARK: - 1. Ivory Classic
    static let ivoryClassic = CardTheme(
        id: "ivory_classic",
        name: "Ivory Classic",
        backgroundColor: Color(hex: 0xF4F1EB),
        textColor: Color(hex: 0x1C1C1E),
        secondaryTextColor: Color(hex: 0x6E6E73),
        accentColor: Color(hex: 0xC6A96B),
        strokeColor: Color(hex: 0xD6D2CB),
        strokeWidth: 0.5,
        layoutStyle: .classic
    )

    // MARK: - 2. Midnight Gold
    static let midnightGold = CardTheme(
        id: "midnight_gold",
        name: "Midnight Gold",
        backgroundColor: Color(hex: 0x141416),
        textColor: Color(hex: 0xF4F1EB),
        secondaryTextColor: Color(hex: 0x8E8E93),
        accentColor: Color(hex: 0xC6A96B),
        strokeColor: Color(hex: 0x2C2C2E),
        strokeWidth: 0.5,
        layoutStyle: .centered
    )

    // MARK: - 3. Slate Silver
    static let slateSilver = CardTheme(
        id: "slate_silver",
        name: "Slate Silver",
        backgroundColor: Color(hex: 0x2C2C2E),
        textColor: Color(hex: 0xE5E5EA),
        secondaryTextColor: Color(hex: 0x8E8E93),
        accentColor: Color(hex: 0xA8A8AD),
        strokeColor: Color(hex: 0x48484A),
        strokeWidth: 0.5,
        layoutStyle: .minimal
    )

    // MARK: - 4. Champagne Dream
    static let champagneDream = CardTheme(
        id: "champagne_dream",
        name: "Champagne Dream",
        backgroundColor: Color(hex: 0xF7F3ED),
        textColor: Color(hex: 0x3A3A3C),
        secondaryTextColor: Color(hex: 0x8E8E93),
        accentColor: Color(hex: 0xD4B880),
        strokeColor: Color(hex: 0xE5DED3),
        strokeWidth: 1.0,
        layoutStyle: .modern
    )

    // MARK: - 5. Obsidian Edge
    static let obsidianEdge = CardTheme(
        id: "obsidian_edge",
        name: "Obsidian Edge",
        backgroundColor: Color(hex: 0x0A0A0A),
        textColor: Color(hex: 0xFFFFFF),
        secondaryTextColor: Color(hex: 0x636366),
        accentColor: Color(hex: 0xFFFFFF),
        strokeColor: Color(hex: 0x1C1C1E),
        strokeWidth: 0,
        layoutStyle: .bold
    )

    // MARK: - 6. Porcelain
    static let porcelain = CardTheme(
        id: "porcelain",
        name: "Porcelain",
        backgroundColor: Color(hex: 0xFAF9F7),
        textColor: Color(hex: 0x2C2C2E),
        secondaryTextColor: Color(hex: 0xAEAEB2),
        accentColor: Color(hex: 0x7C8A96),
        strokeColor: Color(hex: 0xE8E6E2),
        strokeWidth: 0.5,
        layoutStyle: .editorial
    )

    // MARK: - 7. Espresso
    static let espresso = CardTheme(
        id: "espresso",
        name: "Espresso",
        backgroundColor: Color(hex: 0x2A1F17),
        textColor: Color(hex: 0xF4F1EB),
        secondaryTextColor: Color(hex: 0xB9B3A9),
        accentColor: Color(hex: 0xC6A96B),
        strokeColor: Color(hex: 0x3D3028),
        strokeWidth: 0.5,
        layoutStyle: .split
    )

    // MARK: - 8. Arctic Frost
    static let arcticFrost = CardTheme(
        id: "arctic_frost",
        name: "Arctic Frost",
        backgroundColor: Color(hex: 0xF0F4F8),
        textColor: Color(hex: 0x1C2B3A),
        secondaryTextColor: Color(hex: 0x6B7F92),
        accentColor: Color(hex: 0x4A90B8),
        strokeColor: Color(hex: 0xD8E2EC),
        strokeWidth: 0.5,
        layoutStyle: .stacked
    )

    // MARK: - 9. Venetian Night
    static let venetianNight = CardTheme(
        id: "venetian_night",
        name: "Venetian Night",
        backgroundColor: Color(hex: 0x1A1424),
        textColor: Color(hex: 0xEDE9E1),
        secondaryTextColor: Color(hex: 0x8878A0),
        accentColor: Color(hex: 0xC6A96B),
        strokeColor: Color(hex: 0x2D2438),
        strokeWidth: 0.5,
        layoutStyle: .executive
    )

    // MARK: - 10. Sandstone
    static let sandstone = CardTheme(
        id: "sandstone",
        name: "Sandstone",
        backgroundColor: Color(hex: 0xE8DFD0),
        textColor: Color(hex: 0x3C352C),
        secondaryTextColor: Color(hex: 0x8C8478),
        accentColor: Color(hex: 0xA08050),
        strokeColor: Color(hex: 0xD1C8B8),
        strokeWidth: 1.0,
        layoutStyle: .refined
    )

    // MARK: - 11. Carbon Fiber
    static let carbonFiber = CardTheme(
        id: "carbon_fiber",
        name: "Carbon Fiber",
        backgroundColor: Color(hex: 0x1C1C1E),
        textColor: Color(hex: 0xE5E5EA),
        secondaryTextColor: Color(hex: 0x636366),
        accentColor: Color(hex: 0xE5E5EA),
        strokeColor: Color(hex: 0x38383A),
        strokeWidth: 0.5,
        layoutStyle: .asymmetric
    )

    // MARK: - 12. Rose Gold
    static let roseGold = CardTheme(
        id: "rose_gold",
        name: "Rose Gold",
        backgroundColor: Color(hex: 0xFFF5F0),
        textColor: Color(hex: 0x3A2C28),
        secondaryTextColor: Color(hex: 0x9C8880),
        accentColor: Color(hex: 0xC4846C),
        strokeColor: Color(hex: 0xE8D8D0),
        strokeWidth: 0.5,
        layoutStyle: .monogram
    )
}
