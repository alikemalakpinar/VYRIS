import SwiftUI

struct CenteredLayoutView: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(spacing: VYRISSpacing.sm) {
            Spacer()

            Text(card.fullName)
                .font(theme.fontStyle.nameFont(24))
                .foregroundColor(theme.textColor)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            if !card.title.isEmpty {
                Text(card.title)
                    .font(theme.fontStyle.titleFont(14))
                    .foregroundColor(theme.secondaryTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Rectangle()
                .fill(theme.accentColor)
                .frame(width: 40, height: 0.5)

            if !card.company.isEmpty {
                Text(card.company)
                    .font(theme.fontStyle.titleFont(13))
                    .foregroundColor(theme.accentColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer()

            if !card.email.isEmpty {
                Text(card.email)
                    .font(theme.fontStyle.detailFont(11))
                    .foregroundColor(theme.secondaryTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }
}
