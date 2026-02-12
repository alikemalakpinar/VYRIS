import SwiftUI

struct ModernLayoutView: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(alignment: .leading, spacing: VYRISSpacing.xs) {
            if !card.company.isEmpty {
                Text(card.company.uppercased())
                    .font(theme.fontStyle.detailFont(10))
                    .foregroundColor(theme.accentColor)
                    .tracking(2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Text(card.fullName)
                .font(theme.fontStyle.nameFont(20))
                .foregroundColor(theme.textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            if !card.title.isEmpty {
                Text(card.title)
                    .font(theme.fontStyle.titleFont(13))
                    .foregroundColor(theme.secondaryTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer()

            HStack(spacing: VYRISSpacing.md) {
                if !card.phone.isEmpty {
                    Text(card.phone)
                        .font(theme.fontStyle.detailFont(11))
                        .foregroundColor(theme.secondaryTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                if !card.email.isEmpty {
                    Text(card.email)
                        .font(theme.fontStyle.detailFont(11))
                        .foregroundColor(theme.secondaryTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
