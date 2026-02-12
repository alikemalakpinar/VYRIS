import SwiftUI

// MARK: - Card Back View
// Static back face with centered QR code.
// No tilt effect — only the front card has motion.

struct CardBackView: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: VYRISCardDimensions.cornerRadius)
                    .fill(theme.backgroundColor)

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
                        .font(VYRISTypography.cardDetail(size: 11))
                        .foregroundColor(theme.secondaryTextColor)
                        .tracking(0.5)

                    Spacer()

                    // Small brand watermark
                    Text("VYRIS")
                        .font(VYRISTypography.cardDetail(size: 9))
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

// MARK: - Preview

#Preview {
    CardBackView(
        card: .sample,
        theme: ThemeRegistry.ivoryClassic
    )
    .padding()
}
