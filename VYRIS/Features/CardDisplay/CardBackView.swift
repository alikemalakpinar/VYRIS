import SwiftUI

// MARK: - Card Back View
// Static back face with themed QR code.
// Supports decoration overlays and background styles.

struct CardBackView: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Themed background
                CardBackgroundRenderer(theme: theme)
                    .clipShape(RoundedRectangle(cornerRadius: VYRISCardDimensions.cornerRadius))

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

                // Content
                VStack(spacing: VYRISSpacing.md) {
                    Spacer()

                    // QR Code
                    QRCodeView(
                        card: card,
                        size: min(geometry.size.width * 0.45, 180),
                        tintColor: theme.textColor
                    )

                    // Scan instruction — localized
                    Text("qr.scanToAdd")
                        .font(theme.fontStyle.detailFont(11))
                        .foregroundColor(theme.secondaryTextColor)
                        .tracking(0.5)

                    Spacer()

                    // Brand watermark
                    Text("VYRIS")
                        .font(theme.fontStyle.detailFont(9))
                        .foregroundColor(theme.secondaryTextColor.opacity(0.4))
                        .tracking(3)
                        .padding(.bottom, VYRISSpacing.xs)
                }
                .padding(VYRISSpacing.lg)
            }
        }
        .aspectRatio(VYRISCardDimensions.aspectRatio, contentMode: .fit)
    }
}

#Preview {
    CardBackView(card: .sample, theme: ThemeRegistry.ivoryClassic)
        .padding()
}
