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
        case .photoHero:
            PhotoHeroLayout(card: card, theme: theme)
        case .branded:
            BrandedLayout(card: card, theme: theme)
        case .socialGrid:
            SocialGridLayout(card: card, theme: theme)
        case .dualTone:
            DualToneLayout(card: card, theme: theme)
        case .magazine:
            MagazineLayout(card: card, theme: theme)
        case .techCard:
            TechCardLayout(card: card, theme: theme)
        case .profileLeft:
            ProfileLeftLayout(card: card, theme: theme)
        case .panoramic:
            PanoramicLayout(card: card, theme: theme)
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
                    .font(theme.fontStyle.nameFont(22))
                    .foregroundColor(theme.textColor)

                if !card.title.isEmpty {
                    Text(card.title)
                        .font(theme.fontStyle.titleFont(14))
                        .foregroundColor(theme.secondaryTextColor)
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
                if !card.company.isEmpty {
                    Text(card.company)
                        .font(theme.fontStyle.titleFont(13))
                        .foregroundColor(theme.accentColor)
                }

                if !card.email.isEmpty {
                    Text(card.email)
                        .font(theme.fontStyle.detailFont(11))
                        .foregroundColor(theme.secondaryTextColor)
                }

                if !card.phone.isEmpty {
                    Text(card.phone)
                        .font(theme.fontStyle.detailFont(11))
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
                .font(theme.fontStyle.nameFont(24))
                .foregroundColor(theme.textColor)
                .multilineTextAlignment(.center)

            if !card.title.isEmpty {
                Text(card.title)
                    .font(theme.fontStyle.titleFont(14))
                    .foregroundColor(theme.secondaryTextColor)
            }

            Rectangle()
                .fill(theme.accentColor)
                .frame(width: 40, height: 0.5)

            if !card.company.isEmpty {
                Text(card.company)
                    .font(theme.fontStyle.titleFont(13))
                    .foregroundColor(theme.accentColor)
            }

            Spacer()

            if !card.email.isEmpty {
                Text(card.email)
                    .font(theme.fontStyle.detailFont(11))
                    .foregroundColor(theme.secondaryTextColor)
            }
        }
    }
}

// MARK: - 3. Minimal Layout (Name only, large, centered)

private struct MinimalLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack {
            Spacer()

            Text(card.fullName)
                .font(theme.fontStyle.nameFont(28))
                .foregroundColor(theme.textColor)
                .tracking(2)
                .multilineTextAlignment(.center)

            if !card.title.isEmpty {
                Text(card.title)
                    .font(theme.fontStyle.detailFont(11))
                    .foregroundColor(theme.secondaryTextColor)
                    .tracking(3)
                    .textCase(.uppercase)
                    .padding(.top, VYRISSpacing.xs)
            }

            Spacer()
        }
    }
}

// MARK: - 4. Modern Layout (Company uppercase top, name, title, details bottom)

private struct ModernLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(alignment: .leading, spacing: VYRISSpacing.xs) {
            if !card.company.isEmpty {
                Text(card.company.uppercased())
                    .font(theme.fontStyle.detailFont(10))
                    .foregroundColor(theme.accentColor)
                    .tracking(2)
            }

            Text(card.fullName)
                .font(theme.fontStyle.nameFont(20))
                .foregroundColor(theme.textColor)

            if !card.title.isEmpty {
                Text(card.title)
                    .font(theme.fontStyle.titleFont(13))
                    .foregroundColor(theme.secondaryTextColor)
            }

            Spacer()

            HStack(spacing: VYRISSpacing.md) {
                if !card.phone.isEmpty {
                    Text(card.phone)
                        .font(theme.fontStyle.detailFont(11))
                        .foregroundColor(theme.secondaryTextColor)
                }

                if !card.email.isEmpty {
                    Text(card.email)
                        .font(theme.fontStyle.detailFont(11))
                        .foregroundColor(theme.secondaryTextColor)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 5. Editorial Layout (Name right-aligned top, company left-aligned bottom)

private struct EditorialLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: VYRISSpacing.xxs) {
                    Text(card.fullName)
                        .font(theme.fontStyle.nameFont(22))
                        .foregroundColor(theme.textColor)

                    if !card.title.isEmpty {
                        Text(card.title)
                            .font(theme.fontStyle.titleFont(14))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                }
            }

            Spacer()

            HStack {
                VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
                    if !card.company.isEmpty {
                        Text(card.company)
                            .font(theme.fontStyle.titleFont(13))
                            .foregroundColor(theme.accentColor)
                    }

                    if !card.email.isEmpty {
                        Text(card.email)
                            .font(theme.fontStyle.detailFont(11))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                }
                Spacer()
            }
        }
    }
}

// MARK: - 6. Split Layout (Name left, vertical line, details right)

private struct SplitLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
                Text(card.fullName)
                    .font(theme.fontStyle.nameFont(20))
                    .foregroundColor(theme.textColor)

                if !card.title.isEmpty {
                    Text(card.title)
                        .font(theme.fontStyle.titleFont(13))
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
                        .font(theme.fontStyle.titleFont(12))
                        .foregroundColor(theme.accentColor)
                }

                if !card.email.isEmpty {
                    Text(card.email)
                        .font(theme.fontStyle.detailFont(11))
                        .foregroundColor(theme.secondaryTextColor)
                }

                if !card.phone.isEmpty {
                    Text(card.phone)
                        .font(theme.fontStyle.detailFont(11))
                        .foregroundColor(theme.secondaryTextColor)
                }
            }
        }
    }
}

// MARK: - 7. Bold Layout (Huge name, tiny details bottom)

private struct BoldLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(card.fullName)
                .font(theme.fontStyle.nameFont(30))
                .foregroundColor(theme.textColor)
                .minimumScaleFactor(0.7)

            Spacer()

            HStack(alignment: .bottom) {
                if !card.title.isEmpty {
                    Text(card.title.uppercased())
                        .font(theme.fontStyle.detailFont(10))
                        .foregroundColor(theme.secondaryTextColor)
                        .tracking(1.5)
                }
                Spacer()
                if !card.company.isEmpty {
                    Text(card.company)
                        .font(theme.fontStyle.detailFont(10))
                        .foregroundColor(theme.accentColor)
                        .tracking(1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 8. Stacked Layout (Company caps, name, title, email vertically centered)

private struct StackedLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(spacing: VYRISSpacing.sm) {
            Spacer()

            if !card.company.isEmpty {
                Text(card.company.uppercased())
                    .font(theme.fontStyle.detailFont(9))
                    .foregroundColor(theme.accentColor)
                    .tracking(3)
            }

            Text(card.fullName)
                .font(theme.fontStyle.nameFont(22))
                .foregroundColor(theme.textColor)
                .multilineTextAlignment(.center)

            if !card.title.isEmpty {
                Text(card.title)
                    .font(theme.fontStyle.titleFont(13))
                    .foregroundColor(theme.secondaryTextColor)
            }

            if !card.email.isEmpty {
                Text(card.email)
                    .font(theme.fontStyle.detailFont(11))
                    .foregroundColor(theme.secondaryTextColor)
                    .padding(.top, VYRISSpacing.xxs)
            }

            Spacer()
        }
    }
}

// MARK: - 9. Executive Layout (Centered name with horizontal rules around title)

private struct ExecutiveLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(spacing: VYRISSpacing.sm) {
            Spacer()

            Text(card.fullName)
                .font(theme.fontStyle.nameFont(24))
                .foregroundColor(theme.textColor)
                .multilineTextAlignment(.center)

            HStack(spacing: VYRISSpacing.sm) {
                Rectangle().fill(theme.accentColor).frame(width: 20, height: 0.5)
                if !card.title.isEmpty {
                    Text(card.title)
                        .font(theme.fontStyle.detailFont(11))
                        .foregroundColor(theme.secondaryTextColor)
                        .tracking(1)
                }
                Rectangle().fill(theme.accentColor).frame(width: 20, height: 0.5)
            }

            if !card.company.isEmpty {
                Text(card.company)
                    .font(theme.fontStyle.titleFont(12))
                    .foregroundColor(theme.accentColor)
                    .tracking(2)
            }

            Spacer()
        }
    }
}

// MARK: - 10. Refined Layout (All uppercase, heavy tracking, rule, email+phone bottom)

private struct RefinedLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(alignment: .leading, spacing: VYRISSpacing.xs) {
            Text(card.fullName.uppercased())
                .font(theme.fontStyle.detailFont(14))
                .foregroundColor(theme.textColor)
                .tracking(4)

            if !card.title.isEmpty {
                Text(card.title.uppercased())
                    .font(theme.fontStyle.detailFont(10))
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
                        .font(theme.fontStyle.detailFont(10))
                        .foregroundColor(theme.secondaryTextColor)
                }
                Spacer()
                if !card.phone.isEmpty {
                    Text(card.phone)
                        .font(theme.fontStyle.detailFont(10))
                        .foregroundColor(theme.secondaryTextColor)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 11. Asymmetric Layout (Company top-right, name bottom-left, email bottom-right)

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
                            .font(theme.fontStyle.detailFont(9))
                            .foregroundColor(theme.accentColor)
                            .tracking(2)
                    }
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
                Spacer()
                Text(card.fullName)
                    .font(theme.fontStyle.nameFont(22))
                    .foregroundColor(theme.textColor)

                if !card.title.isEmpty {
                    Text(card.title)
                        .font(theme.fontStyle.titleFont(12))
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
                            .font(theme.fontStyle.detailFont(10))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                }
            }
        }
    }
}

// MARK: - 12. Monogram Layout (Large faded initials + compact info right)

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
                    .font(theme.fontStyle.nameFont(18))
                    .foregroundColor(theme.textColor)

                if !card.title.isEmpty {
                    Text(card.title)
                        .font(theme.fontStyle.titleFont(12))
                        .foregroundColor(theme.secondaryTextColor)
                }

                if !card.company.isEmpty {
                    Text(card.company)
                        .font(theme.fontStyle.titleFont(11))
                        .foregroundColor(theme.accentColor)
                        .padding(.top, VYRISSpacing.xxs)
                }
            }

            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - 13. Photo Hero Layout (Profile photo circle top-center, info below)

private struct PhotoHeroLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    private var initials: String {
        let parts = card.fullName.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }.map(String.init)
        return letters.joined()
    }

    var body: some View {
        VStack(spacing: VYRISSpacing.xs) {
            // Profile photo or initials fallback
            if let photo = card.photoImage {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(theme.accentColor)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(initials)
                            .font(theme.fontStyle.nameFont(20))
                            .foregroundColor(.white)
                    )
            }

            Text(card.fullName)
                .font(theme.fontStyle.nameFont(20))
                .foregroundColor(theme.textColor)
                .multilineTextAlignment(.center)

            if !card.title.isEmpty {
                Text(card.title)
                    .font(theme.fontStyle.titleFont(12))
                    .foregroundColor(theme.secondaryTextColor)
            }

            if !card.company.isEmpty {
                Text(card.company)
                    .font(theme.fontStyle.titleFont(11))
                    .foregroundColor(theme.accentColor)
            }

            Spacer()

            if !card.email.isEmpty {
                Text(card.email)
                    .font(theme.fontStyle.detailFont(10))
                    .foregroundColor(theme.secondaryTextColor)
            }
        }
    }
}

// MARK: - 14. Branded Layout (Company large top-left, accent bar, logo bottom-right)

private struct BrandedLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(alignment: .leading, spacing: VYRISSpacing.xs) {
            // Company name large in accent
            if !card.company.isEmpty {
                Text(card.company)
                    .font(theme.fontStyle.nameFont(24))
                    .foregroundColor(theme.accentColor)
                    .minimumScaleFactor(0.7)
            }

            // Bold accent bar
            Rectangle()
                .fill(theme.accentColor)
                .frame(width: 40, height: 3)

            Text(card.fullName)
                .font(theme.fontStyle.nameFont(16))
                .foregroundColor(theme.textColor)

            if !card.title.isEmpty {
                Text(card.title)
                    .font(theme.fontStyle.titleFont(12))
                    .foregroundColor(theme.secondaryTextColor)
            }

            Spacer()

            // Bottom row: contact left, logo right
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
                    if !card.email.isEmpty {
                        Text(card.email)
                            .font(theme.fontStyle.detailFont(10))
                            .foregroundColor(theme.secondaryTextColor)
                    }

                    if !card.phone.isEmpty {
                        Text(card.phone)
                            .font(theme.fontStyle.detailFont(10))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                }

                Spacer()

                if let logo = card.logoImage {
                    Image(uiImage: logo)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 15. Social Grid Layout (Name+title top, social icons bottom)

private struct SocialGridLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(alignment: .leading, spacing: VYRISSpacing.xs) {
            Text(card.fullName)
                .font(theme.fontStyle.nameFont(22))
                .foregroundColor(theme.textColor)

            if !card.title.isEmpty {
                Text(card.title)
                    .font(theme.fontStyle.titleFont(13))
                    .foregroundColor(theme.secondaryTextColor)
            }

            if !card.company.isEmpty {
                Text(card.company)
                    .font(theme.fontStyle.titleFont(11))
                    .foregroundColor(theme.accentColor)
            }

            Spacer()

            // Social link icons row (max 5)
            if !card.socialLinks.isEmpty {
                HStack(spacing: VYRISSpacing.sm) {
                    ForEach(card.socialLinks.prefix(5)) { link in
                        ZStack {
                            Circle()
                                .stroke(theme.accentColor, lineWidth: 1)
                                .frame(width: 28, height: 28)

                            Image(systemName: link.iconName)
                                .font(.system(size: 12))
                                .foregroundColor(theme.accentColor)
                        }
                    }
                }
            }

            if !card.email.isEmpty {
                Text(card.email)
                    .font(theme.fontStyle.detailFont(10))
                    .foregroundColor(theme.secondaryTextColor)
                    .padding(.top, VYRISSpacing.xxs)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 16. Dual Tone Layout (Top half name, bottom half accent region)

private struct DualToneLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Top half — name on card background
                VStack {
                    Spacer()
                    Text(card.fullName)
                        .font(theme.fontStyle.nameFont(24))
                        .foregroundColor(theme.textColor)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height / 2)

                // Bottom half — accent-colored region
                ZStack {
                    theme.accentColor

                    VStack(spacing: VYRISSpacing.xxs) {
                        if !card.title.isEmpty {
                            Text(card.title)
                                .font(theme.fontStyle.titleFont(13))
                                .foregroundColor(.white)
                        }

                        if !card.company.isEmpty {
                            Text(card.company)
                                .font(theme.fontStyle.titleFont(11))
                                .foregroundColor(.white.opacity(0.85))
                        }

                        if !card.email.isEmpty {
                            Text(card.email)
                                .font(theme.fontStyle.detailFont(10))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.top, VYRISSpacing.xxs)
                        }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height / 2)
            }
        }
    }
}

// MARK: - 17. Magazine Layout (Large name, rule, title+company, bio, location)

private struct MagazineLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(alignment: .leading, spacing: VYRISSpacing.xs) {
            // Large condensed name spanning full width
            Text(card.fullName)
                .font(theme.fontStyle.nameFont(26))
                .foregroundColor(theme.textColor)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            // Thin accent rule
            Rectangle()
                .fill(theme.accentColor)
                .frame(height: 1)

            // Title + company on one line
            HStack(spacing: VYRISSpacing.xs) {
                if !card.title.isEmpty {
                    Text(card.title)
                        .font(theme.fontStyle.titleFont(12))
                        .foregroundColor(theme.secondaryTextColor)
                }

                if !card.title.isEmpty && !card.company.isEmpty {
                    Text("·")
                        .font(theme.fontStyle.titleFont(12))
                        .foregroundColor(theme.secondaryTextColor)
                }

                if !card.company.isEmpty {
                    Text(card.company)
                        .font(theme.fontStyle.titleFont(12))
                        .foregroundColor(theme.accentColor)
                }
            }

            // Bio text
            if !card.bio.isEmpty {
                Text(card.bio)
                    .font(theme.fontStyle.detailFont(9))
                    .foregroundColor(theme.secondaryTextColor)
                    .lineLimit(3)
            }

            Spacer()

            // Location at bottom
            if !card.location.isEmpty {
                HStack(spacing: VYRISSpacing.xxs) {
                    Image(systemName: "mappin")
                        .font(.system(size: 8))
                        .foregroundColor(theme.accentColor)

                    Text(card.location)
                        .font(theme.fontStyle.detailFont(9))
                        .foregroundColor(theme.secondaryTextColor)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 18. Tech Card Layout (Monospace, terminal aesthetic)

private struct TechCardLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(alignment: .leading, spacing: VYRISSpacing.xs) {
            // Name with ">" prefix
            Text("> \(card.fullName)")
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .foregroundColor(theme.textColor)

            // Title with "//" prefix
            if !card.title.isEmpty {
                Text("// \(card.title)")
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundColor(theme.secondaryTextColor)
            }

            Spacer()

            // Key:value details
            VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
                if !card.company.isEmpty {
                    Text("org: \(card.company)")
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundColor(theme.accentColor)
                }

                if !card.email.isEmpty {
                    Text("mail: \(card.email)")
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundColor(theme.secondaryTextColor)
                }

                if !card.phone.isEmpty {
                    Text("tel: \(card.phone)")
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundColor(theme.secondaryTextColor)
                }

                if !card.website.isEmpty {
                    Text("web: \(card.website)")
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundColor(theme.secondaryTextColor)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 19. Profile Left Layout (Photo left, info right)

private struct ProfileLeftLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    private var initials: String {
        let parts = card.fullName.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }.map(String.init)
        return letters.joined()
    }

    var body: some View {
        HStack(alignment: .center, spacing: VYRISSpacing.md) {
            // Photo circle on the left
            if let photo = card.photoImage {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(theme.accentColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(initials)
                            .font(theme.fontStyle.nameFont(16))
                            .foregroundColor(theme.accentColor)
                    )
            }

            // Info stacked to the right
            VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
                Text(card.fullName)
                    .font(theme.fontStyle.nameFont(18))
                    .foregroundColor(theme.textColor)

                if !card.title.isEmpty {
                    Text(card.title)
                        .font(theme.fontStyle.titleFont(12))
                        .foregroundColor(theme.secondaryTextColor)
                }

                if !card.company.isEmpty {
                    Text(card.company)
                        .font(theme.fontStyle.titleFont(11))
                        .foregroundColor(theme.accentColor)
                }
            }

            Spacer()
        }
        .frame(maxHeight: .infinity)
        .overlay(alignment: .bottomTrailing) {
            VStack(alignment: .trailing, spacing: VYRISSpacing.xxs) {
                if !card.email.isEmpty {
                    Text(card.email)
                        .font(theme.fontStyle.detailFont(10))
                        .foregroundColor(theme.secondaryTextColor)
                }

                if !card.phone.isEmpty {
                    Text(card.phone)
                        .font(theme.fontStyle.detailFont(10))
                        .foregroundColor(theme.secondaryTextColor)
                }
            }
        }
    }
}

// MARK: - 20. Panoramic Layout (Name top, company bottom, centered middle)

private struct PanoramicLayout: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(spacing: 0) {
            // Name at absolute top
            Text(card.fullName)
                .font(theme.fontStyle.nameFont(22))
                .foregroundColor(theme.textColor)
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer()

            // Centered middle area
            VStack(spacing: VYRISSpacing.xs) {
                if !card.title.isEmpty {
                    Text(card.title)
                        .font(theme.fontStyle.titleFont(13))
                        .foregroundColor(theme.secondaryTextColor)
                }

                Rectangle()
                    .fill(theme.accentColor)
                    .frame(width: 24, height: 0.5)

                if !card.email.isEmpty {
                    Text(card.email)
                        .font(theme.fontStyle.detailFont(10))
                        .foregroundColor(theme.secondaryTextColor)
                }
            }

            Spacer()

            // Company at absolute bottom
            if !card.company.isEmpty {
                Text(card.company.uppercased())
                    .font(theme.fontStyle.detailFont(10))
                    .foregroundColor(theme.accentColor)
                    .tracking(3)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
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
