import SwiftUI

// MARK: - Card Back View
// Etched QR "access key" presentation. Static — no tilt/parallax.
// High contrast for scanability. QR is the back's sole purpose.

struct CardBackView: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Themed background — slightly darkened for contrast
                CardBackgroundRenderer(theme: theme)
                    .clipShape(RoundedRectangle(cornerRadius: VYRISCardDimensions.cornerRadius))

                // Subtle decoration (muted)
                CardDecorationView(
                    style: theme.decorationStyle,
                    accentColor: theme.accentColor.opacity(0.3),
                    secondaryColor: theme.secondaryTextColor.opacity(0.2)
                )
                .clipShape(RoundedRectangle(cornerRadius: VYRISCardDimensions.cornerRadius))

                // Stroke border
                if theme.strokeWidth > 0 {
                    RoundedRectangle(cornerRadius: VYRISCardDimensions.cornerRadius)
                        .strokeBorder(theme.strokeColor, lineWidth: theme.strokeWidth)
                }

                // Content: etched QR key
                VStack(spacing: VYRISSpacing.sm) {
                    Spacer()

                    // "ACCESS KEY" label
                    Text("qr.accessKey")
                        .font(.system(size: 9, weight: .medium, design: .default))
                        .foregroundColor(theme.secondaryTextColor.opacity(0.5))
                        .tracking(3)
                        .textCase(.uppercase)

                    // Etched QR Code — high contrast
                    EtchedQRView(
                        card: card,
                        size: min(geometry.size.width * 0.48, 180),
                        foregroundColor: theme.textColor,
                        glowColor: theme.accentColor
                    )

                    // Scan instruction
                    Text("qr.scanToAdd")
                        .font(theme.fontStyle.detailFont(10))
                        .foregroundColor(theme.secondaryTextColor.opacity(0.6))
                        .tracking(0.5)

                    Spacer()

                    // Bottom: brand + card holder name
                    HStack {
                        Text("VYRIS")
                            .font(.system(size: 8, weight: .light, design: .serif))
                            .foregroundColor(theme.secondaryTextColor.opacity(0.3))
                            .tracking(3)

                        Spacer()

                        Text(card.fullName)
                            .font(.system(size: 8, weight: .regular, design: .serif))
                            .foregroundColor(theme.secondaryTextColor.opacity(0.4))
                            .lineLimit(1)
                    }
                    .padding(.bottom, VYRISSpacing.xs)
                }
                .padding(VYRISSpacing.lg)
            }
        }
        .aspectRatio(VYRISCardDimensions.aspectRatio, contentMode: .fit)
    }
}

// MARK: - Etched QR View
// QR code with subtle "etched" aesthetic — faint glow border, sharp rendering.

struct EtchedQRView: View {
    let card: BusinessCard
    let size: CGFloat
    let foregroundColor: Color
    let glowColor: Color

    var body: some View {
        ZStack {
            // Subtle glow behind QR
            if let image = QRGenerator.generate(for: card, size: size) {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .colorMultiply(glowColor.opacity(0.15))
                    .blur(radius: 4)
            }

            // Sharp QR
            QRCodeView(
                card: card,
                size: size,
                tintColor: foregroundColor
            )
        }
    }
}

#Preview {
    CardBackView(card: .sample, theme: ThemeRegistry.ivoryClassic)
        .padding()
}
