import SwiftUI

// MARK: - Theme Preview Gallery
// Used for browsing all 12 themes with a sample card.

struct ThemePreviewView: View {
    @State private var selectedTheme: CardTheme = ThemeRegistry.ivoryClassic

    var body: some View {
        ZStack {
            VYRISBackground()

            VStack(spacing: VYRISSpacing.lg) {
                Text("Themes")
                    .font(VYRISTypography.title())
                    .foregroundColor(VYRISColors.Semantic.textPrimary)

                // Active theme preview
                CardFrontView(
                    card: .sample,
                    theme: selectedTheme,
                    tiltX: 0,
                    tiltY: 0,
                    motionEnabled: false
                )
                .padding(.horizontal, VYRISSpacing.xl)
                .vyrisShadow(VYRISShadow.cardResting)

                Text(selectedTheme.name)
                    .font(VYRISTypography.meta())
                    .foregroundColor(VYRISColors.Semantic.textSecondary)
                    .tracking(2)
                    .textCase(.uppercase)

                // Theme grid
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.adaptive(minimum: 80), spacing: VYRISSpacing.sm)
                        ],
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
            RoundedRectangle(cornerRadius: 10)
                .fill(theme.backgroundColor)
                .aspectRatio(VYRISCardDimensions.aspectRatio, contentMode: .fit)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            isSelected ? VYRISColors.Semantic.accent : theme.strokeColor,
                            lineWidth: isSelected ? 2 : 0.5
                        )
                )
                .overlay(
                    Text("Aa")
                        .font(.system(size: 14, weight: .light, design: .serif))
                        .foregroundColor(theme.textColor)
                )

            Text(theme.name)
                .font(VYRISTypography.caption())
                .foregroundColor(VYRISColors.Semantic.textSecondary)
                .lineLimit(1)
        }
        .onTapGesture {
            VYRISHaptics.selection()
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTheme = theme
            }
        }
    }
}

#Preview {
    ThemePreviewView()
}
