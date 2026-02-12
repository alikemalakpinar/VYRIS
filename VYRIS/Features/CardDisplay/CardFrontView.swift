import SwiftUI

// MARK: - Card Front View
// Renders the front face of a business card with the appropriate theme layout.
// Supports subtle tilt via CoreMotion with parallax text offset.
// Layout selection delegated to CardLayoutFactory.

struct CardFrontView: View {
    let card: BusinessCard
    let theme: CardTheme
    let tiltX: Double
    let tiltY: Double
    let motionEnabled: Bool

    private var parallaxOffset: CGSize {
        guard motionEnabled else { return .zero }
        return CGSize(width: tiltY * 1.5, height: -tiltX * 1.5)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Card background with style support
                RoundedRectangle(cornerRadius: VYRISCardDimensions.cornerRadius)
                    .fill(.clear)
                    .background(
                        CardBackgroundRenderer(theme: theme)
                            .clipShape(RoundedRectangle(cornerRadius: VYRISCardDimensions.cornerRadius))
                    )

                // Decoration overlay
                CardDecorationView(
                    style: theme.decorationStyle,
                    accentColor: theme.accentColor,
                    secondaryColor: theme.secondaryTextColor
                )
                .clipShape(RoundedRectangle(cornerRadius: VYRISCardDimensions.cornerRadius))

                // Stroke border
                if theme.strokeWidth > 0 {
                    RoundedRectangle(cornerRadius: VYRISCardDimensions.cornerRadius)
                        .strokeBorder(theme.strokeColor, lineWidth: theme.strokeWidth)
                }

                // Layout content with parallax
                CardLayoutFactory.layout(for: theme.layoutStyle, card: card, theme: theme)
                    .offset(parallaxOffset)
                    .padding(VYRISSpacing.lg)
            }
        }
        .aspectRatio(VYRISCardDimensions.aspectRatio, contentMode: .fit)
    }
}

// MARK: - Preview

#Preview {
    CardFrontView(
        card: .sample,
        theme: ThemeRegistry.ivoryClassic,
        tiltX: 0,
        tiltY: 0,
        motionEnabled: false
    )
    .padding()
}
