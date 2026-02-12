import SwiftUI

// MARK: - Theme Registry
// 12 premium themes — each dramatically distinct in palette, layout, decoration, and typography.

enum ThemeRegistry {

    static let allThemes: [CardTheme] = [
        ivoryClassic,
        midnightGold,
        neonMint,
        coralSunset,
        navyExecutive,
        arcticMinimal,
        electricViolet,
        forestCorporate,
        warmTerracotta,
        tokyoNeon,
        swissDesign,
        roseGold
    ]

    static func theme(for id: String) -> CardTheme {
        allThemes.first(where: { $0.id == id }) ?? ivoryClassic
    }

    // MARK: - 1. Ivory Classic
    // Warm ivory canvas with soft ink text and champagne gold accents.
    // Timeless, understated elegance — the default prestige card.
    static let ivoryClassic = CardTheme(
        id: "ivory_classic",
        name: "Ivory Classic",
        backgroundColor: Color(hex: 0xF4F1EB),
        textColor: Color(hex: 0x2C2C2E),
        secondaryTextColor: Color(hex: 0x6E6E73),
        accentColor: Color(hex: 0xC6A96B),
        strokeColor: Color(hex: 0xD6D2CB),
        strokeWidth: 0.5,
        layoutStyle: .classic,
        decorationStyle: .cornerLines,
        fontStyle: .serif,
        backgroundStyle: .solid
    )

    // MARK: - 2. Midnight Gold
    // Deep black fading to charcoal with opulent gold framing.
    // The quintessential dark luxury card — bold, cinematic, and premium.
    static let midnightGold = CardTheme(
        id: "midnight_gold",
        name: "Midnight Gold",
        backgroundColor: Color(hex: 0x0C0C0E),
        secondaryBackgroundColor: Color(hex: 0x1A1A1F),
        textColor: Color(hex: 0xF4F1EB),
        secondaryTextColor: Color(hex: 0x8E8E93),
        accentColor: Color(hex: 0xD4AF37),
        strokeColor: Color(hex: 0x2C2C2E),
        strokeWidth: 0.5,
        layoutStyle: .centered,
        decorationStyle: .geometricFrame,
        fontStyle: .serif,
        backgroundStyle: .gradient
    )

    // MARK: - 3. Neon Mint
    // Dark oceanic base with electric mint highlights.
    // Futuristic tech aesthetic — clean, glowing, and razor-sharp.
    static let neonMint = CardTheme(
        id: "neon_mint",
        name: "Neon Mint",
        backgroundColor: Color(hex: 0x0D1B1E),
        textColor: Color(hex: 0xFFFFFF),
        secondaryTextColor: Color(hex: 0x7FAEA3),
        accentColor: Color(hex: 0x00E5A0),
        strokeColor: Color(hex: 0x1A3A3F),
        strokeWidth: 0.5,
        layoutStyle: .techCard,
        decorationStyle: .circuitLines,
        fontStyle: .sansSerif,
        backgroundStyle: .solid
    )

    // MARK: - 4. Coral Sunset
    // Warm cream canvas with a vibrant coral punch.
    // Friendly yet polished — optimistic energy with a designer's hand.
    static let coralSunset = CardTheme(
        id: "coral_sunset",
        name: "Coral Sunset",
        backgroundColor: Color(hex: 0xFFF5F0),
        textColor: Color(hex: 0x2D2420),
        secondaryTextColor: Color(hex: 0x8C7A72),
        accentColor: Color(hex: 0xFF6B5A),
        strokeColor: Color(hex: 0xE8D8D0),
        strokeWidth: 0.5,
        layoutStyle: .modern,
        decorationStyle: .accentBar,
        fontStyle: .sansSerif,
        backgroundStyle: .solid
    )

    // MARK: - 5. Navy Executive
    // Deep navy field with muted gold insignia.
    // Commanding corporate authority — the boardroom power card.
    static let navyExecutive = CardTheme(
        id: "navy_executive",
        name: "Navy Executive",
        backgroundColor: Color(hex: 0x0A1628),
        textColor: Color(hex: 0xE8E6E2),
        secondaryTextColor: Color(hex: 0x7A8A9C),
        accentColor: Color(hex: 0xB8960C),
        strokeColor: Color(hex: 0x1C2E48),
        strokeWidth: 0.5,
        layoutStyle: .executive,
        decorationStyle: .borderAccent,
        fontStyle: .serif,
        backgroundStyle: .solid
    )

    // MARK: - 6. Arctic Minimal
    // Near-white canvas with subtle ice-blue accents.
    // Maximum whitespace, zero noise — Swiss-inspired restraint.
    static let arcticMinimal = CardTheme(
        id: "arctic_minimal",
        name: "Arctic Minimal",
        backgroundColor: Color(hex: 0xFAFBFC),
        textColor: Color(hex: 0x1A1A1A),
        secondaryTextColor: Color(hex: 0x8C8C8C),
        accentColor: Color(hex: 0x4A9CC9),
        strokeColor: Color(hex: 0xE0E4E8),
        strokeWidth: 0.5,
        layoutStyle: .minimal,
        decorationStyle: .none,
        fontStyle: .sansSerif,
        backgroundStyle: .solid
    )

    // MARK: - 7. Electric Violet
    // Deep purple atmosphere with electric violet energy.
    // Nocturnal creative spirit — immersive, magnetic, and daring.
    static let electricViolet = CardTheme(
        id: "electric_violet",
        name: "Electric Violet",
        backgroundColor: Color(hex: 0x12081F),
        secondaryBackgroundColor: Color(hex: 0x1E1035),
        textColor: Color(hex: 0xEDE9F6),
        secondaryTextColor: Color(hex: 0x9B8ABF),
        accentColor: Color(hex: 0x8B5CF6),
        strokeColor: Color(hex: 0x2A1848),
        strokeWidth: 0.5,
        layoutStyle: .magazine,
        decorationStyle: .concentricCircles,
        fontStyle: .sansSerif,
        backgroundStyle: .diagonalGradient
    )

    // MARK: - 8. Forest Corporate
    // Clean off-white with deep forest green authority.
    // Natural sophistication — sustainable luxury meets corporate clarity.
    static let forestCorporate = CardTheme(
        id: "forest_corporate",
        name: "Forest Corporate",
        backgroundColor: Color(hex: 0xF5F5F0),
        textColor: Color(hex: 0x1C1C1E),
        secondaryTextColor: Color(hex: 0x6E7A6E),
        accentColor: Color(hex: 0x1B5E20),
        strokeColor: Color(hex: 0xD4D8D0),
        strokeWidth: 0.5,
        layoutStyle: .branded,
        decorationStyle: .cornerBadge,
        fontStyle: .serif,
        backgroundStyle: .solid
    )

    // MARK: - 9. Warm Terracotta
    // Earthy beige canvas with rich terracotta strokes.
    // Artisanal warmth — handcrafted feel with editorial finesse.
    static let warmTerracotta = CardTheme(
        id: "warm_terracotta",
        name: "Warm Terracotta",
        backgroundColor: Color(hex: 0xF5EBE0),
        textColor: Color(hex: 0x3E2723),
        secondaryTextColor: Color(hex: 0x8D6E63),
        accentColor: Color(hex: 0xC1613D),
        strokeColor: Color(hex: 0xD7C4B0),
        strokeWidth: 0.5,
        layoutStyle: .editorial,
        decorationStyle: .wavePattern,
        fontStyle: .serif,
        backgroundStyle: .solid
    )

    // MARK: - 10. Tokyo Neon
    // Pitch black void with searing hot-pink neon.
    // Cyberpunk electricity — raw, confrontational, unforgettable.
    static let tokyoNeon = CardTheme(
        id: "tokyo_neon",
        name: "Tokyo Neon",
        backgroundColor: Color(hex: 0x0A0A0F),
        secondaryBackgroundColor: Color(hex: 0x1A0A1E),
        textColor: Color(hex: 0xFFFFFF),
        secondaryTextColor: Color(hex: 0x9A8A9E),
        accentColor: Color(hex: 0xFF2D78),
        strokeColor: Color(hex: 0x2A1A2E),
        strokeWidth: 0.5,
        layoutStyle: .bold,
        decorationStyle: .diagonalSlash,
        fontStyle: .condensed,
        backgroundStyle: .radialGlow
    )

    // MARK: - 11. Swiss Design
    // Pure white field, absolute black type, signal red accent.
    // International typographic discipline — grid-perfect and iconic.
    static let swissDesign = CardTheme(
        id: "swiss_design",
        name: "Swiss Design",
        backgroundColor: Color(hex: 0xFFFFFF),
        textColor: Color(hex: 0x000000),
        secondaryTextColor: Color(hex: 0x4A4A4A),
        accentColor: Color(hex: 0xFF0000),
        strokeColor: Color(hex: 0xD0D0D0),
        strokeWidth: 0.5,
        layoutStyle: .stacked,
        decorationStyle: .dotGrid,
        fontStyle: .mono,
        backgroundStyle: .solid
    )

    // MARK: - 12. Rose Gold
    // Soft blush canvas with warm rose-gold metallic tones.
    // Refined feminine luxury — delicate, warm, and unmistakably premium.
    static let roseGold = CardTheme(
        id: "rose_gold",
        name: "Rose Gold",
        backgroundColor: Color(hex: 0xFFF0F0),
        textColor: Color(hex: 0x3A2C28),
        secondaryTextColor: Color(hex: 0x9C8880),
        accentColor: Color(hex: 0xC4846C),
        strokeColor: Color(hex: 0xE8D8D0),
        strokeWidth: 0.5,
        layoutStyle: .profileLeft,
        decorationStyle: .diamondGrid,
        fontStyle: .rounded,
        backgroundStyle: .solid
    )
}
