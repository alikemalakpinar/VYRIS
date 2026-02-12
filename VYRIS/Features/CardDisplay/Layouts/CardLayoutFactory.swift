import SwiftUI

// MARK: - Card Layout Factory
// Routes a CardLayoutStyle to the corresponding layout view.

enum CardLayoutFactory {

    @ViewBuilder
    static func layout(
        for style: CardLayoutStyle,
        card: BusinessCard,
        theme: CardTheme
    ) -> some View {
        switch style {
        case .classic:
            ClassicLayoutView(card: card, theme: theme)
        case .centered:
            CenteredLayoutView(card: card, theme: theme)
        case .minimal:
            MinimalLayoutView(card: card, theme: theme)
        case .modern:
            ModernLayoutView(card: card, theme: theme)
        case .editorial:
            EditorialLayoutView(card: card, theme: theme)
        case .split:
            SplitLayoutView(card: card, theme: theme)
        case .bold:
            BoldLayoutView(card: card, theme: theme)
        case .stacked:
            StackedLayoutView(card: card, theme: theme)
        case .executive:
            ExecutiveLayoutView(card: card, theme: theme)
        case .refined:
            RefinedLayoutView(card: card, theme: theme)
        case .asymmetric:
            AsymmetricLayoutView(card: card, theme: theme)
        case .monogram:
            MonogramLayoutView(card: card, theme: theme)
        case .photoHero:
            PhotoHeroLayoutView(card: card, theme: theme)
        case .branded:
            BrandedLayoutView(card: card, theme: theme)
        case .socialGrid:
            SocialGridLayoutView(card: card, theme: theme)
        case .dualTone:
            DualToneLayoutView(card: card, theme: theme)
        case .magazine:
            MagazineLayoutView(card: card, theme: theme)
        case .techCard:
            TechCardLayoutView(card: card, theme: theme)
        case .profileLeft:
            ProfileLeftLayoutView(card: card, theme: theme)
        case .panoramic:
            PanoramicLayoutView(card: card, theme: theme)
        }
    }
}
