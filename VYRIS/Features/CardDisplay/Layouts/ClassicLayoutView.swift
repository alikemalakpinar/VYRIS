import SwiftUI

struct ClassicLayoutView: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
                Text(card.fullName)
                    .font(theme.fontStyle.nameFont(22))
                    .foregroundColor(theme.textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                if !card.title.isEmpty {
                    Text(card.title)
                        .font(theme.fontStyle.titleFont(14))
                        .foregroundColor(theme.secondaryTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
                if !card.company.isEmpty {
                    Text(card.company)
                        .font(theme.fontStyle.titleFont(13))
                        .foregroundColor(theme.accentColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                if !card.email.isEmpty {
                    Text(card.email)
                        .font(theme.fontStyle.detailFont(11))
                        .foregroundColor(theme.secondaryTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                if !card.phone.isEmpty {
                    Text(card.phone)
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
