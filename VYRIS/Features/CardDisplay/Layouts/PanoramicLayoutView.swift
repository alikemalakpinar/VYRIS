import SwiftUI

struct PanoramicLayoutView: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(spacing: 0) {
            Text(card.fullName)
                .font(theme.fontStyle.nameFont(22))
                .foregroundColor(theme.textColor)
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer()

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
