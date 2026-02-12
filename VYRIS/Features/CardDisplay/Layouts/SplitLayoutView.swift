import SwiftUI

struct SplitLayoutView: View {
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
