import SwiftUI

struct AsymmetricLayoutView: View {
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
