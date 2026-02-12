import SwiftUI

struct BrandedLayoutView: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(alignment: .leading, spacing: VYRISSpacing.xs) {
            if !card.company.isEmpty {
                Text(card.company)
                    .font(theme.fontStyle.nameFont(24))
                    .foregroundColor(theme.accentColor)
                    .minimumScaleFactor(0.7)
            }

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
