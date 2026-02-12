import SwiftUI

// MARK: - Theme Preview Gallery
// Browse all themes with live preview + decoration/background showcase.

struct ThemePreviewView: View {
    @State private var selectedTheme: CardTheme = ThemeRegistry.ivoryClassic

    var body: some View {
        ZStack {
            VYRISBackground()

            VStack(spacing: VYRISSpacing.lg) {
                Text("Themes")
                    .font(VYRISTypography.title())
                    .foregroundColor(VYRISColors.Semantic.textPrimary)

                CardFrontView(
                    card: .sample,
                    theme: selectedTheme,
                    tiltX: 0, tiltY: 0,
                    motionEnabled: false
                )
                .padding(.horizontal, VYRISSpacing.xl)
                .vyrisShadow(VYRISShadow.cardResting)

                HStack(spacing: VYRISSpacing.sm) {
                    Text(selectedTheme.name)
                        .font(VYRISTypography.meta())
                        .foregroundColor(VYRISColors.Semantic.textSecondary)
                        .tracking(2).textCase(.uppercase)

                    Text(selectedTheme.layoutStyle.displayName)
                        .font(VYRISTypography.caption())
                        .foregroundColor(VYRISColors.Semantic.accent)
                        .padding(.horizontal, 8).padding(.vertical, 2)
                        .background(Capsule().fill(VYRISColors.Semantic.accent.opacity(0.1)))
                }

                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 90), spacing: VYRISSpacing.sm)],
                        spacing: VYRISSpacing.sm
                    ) {
                        ForEach(ThemeRegistry.allThemes) { theme in
                            themeCell(theme)
                        }
                    }
                    .padding(.horizontal, VYRISSpacing.lg)
                }
            }
            .padding(.top, VYRISSpacing.lg)
        }
    }

    private func themeCell(_ theme: CardTheme) -> some View {
        let isSelected = theme.id == selectedTheme.id
        return VStack(spacing: VYRISSpacing.xxs) {
            ZStack {
                CardBackgroundRenderer(theme: theme)
                CardDecorationView(
                    style: theme.decorationStyle,
                    accentColor: theme.accentColor,
                    secondaryColor: theme.secondaryTextColor
                )
                Text("Aa")
                    .font(theme.fontStyle.nameFont(14))
                    .foregroundColor(theme.textColor)
            }
            .aspectRatio(VYRISCardDimensions.aspectRatio, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isSelected ? VYRISColors.Semantic.accent : theme.strokeColor,
                                  lineWidth: isSelected ? 2 : 0.5)
            )

            Text(theme.name)
                .font(VYRISTypography.caption())
                .foregroundColor(VYRISColors.Semantic.textSecondary)
                .lineLimit(1)
        }
        .onTapGesture {
            VYRISHaptics.selection()
            withAnimation(.easeInOut(duration: 0.3)) { selectedTheme = theme }
        }
    }
}

#Preview { ThemePreviewView() }
