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
