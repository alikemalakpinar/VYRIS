import SwiftUI

// MARK: - Card Front View
// Renders the front face of a business card with the appropriate theme layout.
// Supports subtle tilt via CoreMotion with parallax text offset.

struct CardFrontView: View {
    let card: BusinessCard
    let theme: CardTheme
    let tiltX: Double
    let tiltY: Double
    let motionEnabled: Bool

    private var parallaxOffset: CGSize {
        guard motionEnabled else { return .zero }
        return CGSize(
            width: tiltY * 1.5,
            height: -tiltX * 1.5
        )
    }

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

                // Layout content with parallax
                cardLayout(for: theme.layoutStyle, in: geometry)
                    .offset(parallaxOffset)
                    .padding(VYRISSpacing.lg)
            }
        }
        .aspectRatio(VYRISCardDimensions.aspectRatio, contentMode: .fit)
    }

    // MARK: - Layout Router

    @ViewBuilder
    private func cardLayout(for style: CardLayoutStyle, in geometry: GeometryProxy) -> some View {
        switch style {
        case .classic:
            ClassicLayout(card: card, theme: theme)
        case .centered:
            CenteredLayout(card: card, theme: theme)
        case .minimal:
            MinimalLayout(card: card, theme: theme)
        case .modern:
            ModernLayout(card: card, theme: theme)
        case .editorial:
            EditorialLayout(card: card, theme: theme)
        case .split:
            SplitLayout(card: card, theme: theme)
        case .bold:
            BoldLayout(card: card, theme: theme)
        case .stacked:
            StackedLayout(card: card, theme: theme)
        case .executive:
            ExecutiveLayout(card: card, theme: theme)
        case .refined:
            RefinedLayout(card: card, theme: theme)
        case .asymmetric:
            AsymmetricLayout(card: card, theme: theme)
        case .monogram:
            MonogramLayout(card: card, theme: theme)
        }
    }
}

// MARK: - 1. Classic Layout (Name top-left, details bottom)

private struct ClassicLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
                Text(card.fullName)
                    .font(VYRISTypography.cardName())
                    .foregroundColor(theme.textColor)

                if !card.title.isEmpty {
                    Text(card.title)
                        .font(VYRISTypography.cardTitle())
                        .foregroundColor(theme.secondaryTextColor)
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
                if !card.company.isEmpty {
                    Text(card.company)
                        .font(VYRISTypography.cardCompany())
                        .foregroundColor(theme.accentColor)
                }

                if !card.email.isEmpty {
                    Text(card.email)
                        .font(VYRISTypography.cardDetail())
                        .foregroundColor(theme.secondaryTextColor)
                }

                if !card.phone.isEmpty {
                    Text(card.phone)
                        .font(VYRISTypography.cardDetail())
                        .foregroundColor(theme.secondaryTextColor)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 2. Centered Layout

private struct CenteredLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(spacing: VYRISSpacing.sm) {
            Spacer()

            Text(card.fullName)
                .font(VYRISTypography.cardName(size: 24))
                .foregroundColor(theme.textColor)
                .multilineTextAlignment(.center)

            if !card.title.isEmpty {
                Text(card.title)
                    .font(VYRISTypography.cardTitle())
                    .foregroundColor(theme.secondaryTextColor)
            }

            Rectangle()
                .fill(theme.accentColor)
                .frame(width: 40, height: 0.5)

            if !card.company.isEmpty {
                Text(card.company)
                    .font(VYRISTypography.cardCompany())
                    .foregroundColor(theme.accentColor)
            }

            Spacer()

            if !card.email.isEmpty {
                Text(card.email)
                    .font(VYRISTypography.cardDetail())
                    .foregroundColor(theme.secondaryTextColor)
            }
        }
    }
}

// MARK: - 3. Minimal Layout (Name only, large serif)

private struct MinimalLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack {
            Spacer()

            Text(card.fullName)
                .font(VYRISTypography.cardName(size: 28))
                .foregroundColor(theme.textColor)
                .tracking(2)
                .multilineTextAlignment(.center)

            if !card.title.isEmpty {
                Text(card.title)
                    .font(VYRISTypography.cardDetail(size: 11))
                    .foregroundColor(theme.secondaryTextColor)
                    .tracking(3)
                    .textCase(.uppercase)
                    .padding(.top, VYRISSpacing.xs)
            }

            Spacer()
        }
    }
}

// MARK: - 4. Modern Layout (Left-aligned, tight spacing)

private struct ModernLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(alignment: .leading, spacing: VYRISSpacing.xs) {
            if !card.company.isEmpty {
                Text(card.company.uppercased())
                    .font(VYRISTypography.cardDetail(size: 10))
                    .foregroundColor(theme.accentColor)
                    .tracking(2)
            }

            Text(card.fullName)
                .font(VYRISTypography.cardName(size: 20))
                .foregroundColor(theme.textColor)

            if !card.title.isEmpty {
                Text(card.title)
                    .font(VYRISTypography.cardTitle(size: 13))
                    .foregroundColor(theme.secondaryTextColor)
            }

            Spacer()

            HStack(spacing: VYRISSpacing.md) {
                if !card.phone.isEmpty {
                    Text(card.phone)
                        .font(VYRISTypography.cardDetail(size: 11))
                        .foregroundColor(theme.secondaryTextColor)
                }

                if !card.email.isEmpty {
                    Text(card.email)
                        .font(VYRISTypography.cardDetail(size: 11))
                        .foregroundColor(theme.secondaryTextColor)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 5. Editorial Layout (Right name, left details)

private struct EditorialLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: VYRISSpacing.xxs) {
                    Text(card.fullName)
                        .font(VYRISTypography.cardName())
                        .foregroundColor(theme.textColor)

                    if !card.title.isEmpty {
                        Text(card.title)
                            .font(VYRISTypography.cardTitle())
                            .foregroundColor(theme.secondaryTextColor)
                    }
                }
            }

            Spacer()

            HStack {
                VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
                    if !card.company.isEmpty {
                        Text(card.company)
                            .font(VYRISTypography.cardCompany())
                            .foregroundColor(theme.accentColor)
                    }

                    if !card.email.isEmpty {
                        Text(card.email)
                            .font(VYRISTypography.cardDetail())
                            .foregroundColor(theme.secondaryTextColor)
                    }
                }
                Spacer()
            }
        }
    }
}

// MARK: - 6. Split Layout (Name left, details right)

private struct SplitLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
                Text(card.fullName)
                    .font(VYRISTypography.cardName(size: 20))
                    .foregroundColor(theme.textColor)

                if !card.title.isEmpty {
                    Text(card.title)
                        .font(VYRISTypography.cardTitle())
                        .foregroundColor(theme.secondaryTextColor)
                }
            }

            Spacer()

            Rectangle()
                .fill(theme.accentColor)
                .frame(width: 0.5, height: 50)

            VStack(alignment: .trailing, spacing: VYRISSpacing.xxs) {
                if !card.company.isEmpty {
                    Text(card.company)
                        .font(VYRISTypography.cardCompany(size: 12))
                        .foregroundColor(theme.accentColor)
                }

                if !card.email.isEmpty {
                    Text(card.email)
                        .font(VYRISTypography.cardDetail(size: 11))
                        .foregroundColor(theme.secondaryTextColor)
                }

                if !card.phone.isEmpty {
                    Text(card.phone)
                        .font(VYRISTypography.cardDetail(size: 11))
                        .foregroundColor(theme.secondaryTextColor)
                }
            }
        }
    }
}

// MARK: - 7. Bold Layout (Large name, small details)

private struct BoldLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(card.fullName)
                .font(VYRISTypography.cardName(size: 30))
                .foregroundColor(theme.textColor)
                .minimumScaleFactor(0.7)

            Spacer()

            HStack(alignment: .bottom) {
                if !card.title.isEmpty {
                    Text(card.title.uppercased())
                        .font(VYRISTypography.cardDetail(size: 10))
                        .foregroundColor(theme.secondaryTextColor)
                        .tracking(1.5)
                }
                Spacer()
                if !card.company.isEmpty {
                    Text(card.company)
                        .font(VYRISTypography.cardDetail(size: 10))
                        .foregroundColor(theme.accentColor)
                        .tracking(1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 8. Stacked Layout (Vertical stack, generous spacing)

private struct StackedLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(spacing: VYRISSpacing.sm) {
            Spacer()

            if !card.company.isEmpty {
                Text(card.company.uppercased())
                    .font(VYRISTypography.cardDetail(size: 9))
                    .foregroundColor(theme.accentColor)
                    .tracking(3)
            }

            Text(card.fullName)
                .font(VYRISTypography.cardName(size: 22))
                .foregroundColor(theme.textColor)
                .multilineTextAlignment(.center)

            if !card.title.isEmpty {
                Text(card.title)
                    .font(VYRISTypography.cardTitle(size: 13))
                    .foregroundColor(theme.secondaryTextColor)
            }

            if !card.email.isEmpty {
                Text(card.email)
                    .font(VYRISTypography.cardDetail(size: 11))
                    .foregroundColor(theme.secondaryTextColor)
                    .padding(.top, VYRISSpacing.xxs)
            }

            Spacer()
        }
    }
}

// MARK: - 9. Executive Layout (Centered name, rule separator)

private struct ExecutiveLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(spacing: VYRISSpacing.sm) {
            Spacer()

            Text(card.fullName)
                .font(VYRISTypography.cardName(size: 24))
                .foregroundColor(theme.textColor)
                .multilineTextAlignment(.center)

            HStack(spacing: VYRISSpacing.sm) {
                Rectangle().fill(theme.accentColor).frame(width: 20, height: 0.5)
                if !card.title.isEmpty {
                    Text(card.title)
                        .font(VYRISTypography.cardDetail(size: 11))
                        .foregroundColor(theme.secondaryTextColor)
                        .tracking(1)
                }
                Rectangle().fill(theme.accentColor).frame(width: 20, height: 0.5)
            }

            if !card.company.isEmpty {
                Text(card.company)
                    .font(VYRISTypography.cardCompany(size: 12))
                    .foregroundColor(theme.accentColor)
                    .tracking(2)
            }

            Spacer()
        }
    }
}

// MARK: - 10. Refined Layout (Small caps, tracked text)

private struct RefinedLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(alignment: .leading, spacing: VYRISSpacing.xs) {
            Text(card.fullName.uppercased())
                .font(VYRISTypography.cardDetail(size: 14))
                .foregroundColor(theme.textColor)
                .tracking(4)

            if !card.title.isEmpty {
                Text(card.title.uppercased())
                    .font(VYRISTypography.cardDetail(size: 10))
                    .foregroundColor(theme.secondaryTextColor)
                    .tracking(3)
            }

            Spacer()

            Rectangle()
                .fill(theme.accentColor)
                .frame(height: 0.5)

            HStack {
                if !card.email.isEmpty {
                    Text(card.email)
                        .font(VYRISTypography.cardDetail(size: 10))
                        .foregroundColor(theme.secondaryTextColor)
                }
                Spacer()
                if !card.phone.isEmpty {
                    Text(card.phone)
                        .font(VYRISTypography.cardDetail(size: 10))
                        .foregroundColor(theme.secondaryTextColor)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 11. Asymmetric Layout (Off-grid artistic)

private struct AsymmetricLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    if !card.company.isEmpty {
                        Text(card.company.uppercased())
                            .font(VYRISTypography.cardDetail(size: 9))
                            .foregroundColor(theme.accentColor)
                            .tracking(2)
                    }
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
                Spacer()
                Text(card.fullName)
                    .font(VYRISTypography.cardName(size: 22))
                    .foregroundColor(theme.textColor)

                if !card.title.isEmpty {
                    Text(card.title)
                        .font(VYRISTypography.cardTitle(size: 12))
                        .foregroundColor(theme.secondaryTextColor)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if !card.email.isEmpty {
                        Text(card.email)
                            .font(VYRISTypography.cardDetail(size: 10))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                }
            }
        }
    }
}

// MARK: - 12. Monogram Layout (Large initial + compact info)

private struct MonogramLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    private var monogram: String {
        let parts = card.fullName.split(separator: " ")
        let initials = parts.prefix(2).compactMap { $0.first }.map(String.init)
        return initials.joined()
    }

    var body: some View {
        HStack(spacing: VYRISSpacing.md) {
            Text(monogram)
                .font(.system(size: 48, weight: .ultraLight, design: .serif))
                .foregroundColor(theme.accentColor.opacity(0.3))

            VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
                Text(card.fullName)
                    .font(VYRISTypography.cardName(size: 18))
                    .foregroundColor(theme.textColor)

                if !card.title.isEmpty {
                    Text(card.title)
                        .font(VYRISTypography.cardTitle(size: 12))
                        .foregroundColor(theme.secondaryTextColor)
                }

                if !card.company.isEmpty {
                    Text(card.company)
                        .font(VYRISTypography.cardCompany(size: 11))
                        .foregroundColor(theme.accentColor)
                        .padding(.top, VYRISSpacing.xxs)
                }
            }

            Spacer()
        }
        .frame(maxHeight: .infinity)
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
