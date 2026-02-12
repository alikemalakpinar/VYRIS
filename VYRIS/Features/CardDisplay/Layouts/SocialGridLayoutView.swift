import SwiftUI

struct SocialGridLayoutView: View {
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
