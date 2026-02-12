import SwiftUI

struct EditorialLayoutView: View {
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
