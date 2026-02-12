import SwiftUI

struct StackedLayoutView: View {
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
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Text(card.fullName)
                .font(theme.fontStyle.nameFont(22))
                .foregroundColor(theme.textColor)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            if !card.title.isEmpty {
                Text(card.title)
                    .font(theme.fontStyle.titleFont(13))
                    .foregroundColor(theme.secondaryTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            if !card.email.isEmpty {
                Text(card.email)
                    .font(theme.fontStyle.detailFont(11))
                    .foregroundColor(theme.secondaryTextColor)
                    .padding(.top, VYRISSpacing.xxs)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer()
        }
    }
}
