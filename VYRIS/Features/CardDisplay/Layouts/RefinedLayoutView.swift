import SwiftUI

struct RefinedLayoutView: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(alignment: .leading, spacing: VYRISSpacing.xs) {
            Text(card.fullName.uppercased())
                .font(theme.fontStyle.detailFont(14))
                .foregroundColor(theme.textColor)
                .tracking(4)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            if !card.title.isEmpty {
                Text(card.title.uppercased())
                    .font(theme.fontStyle.detailFont(10))
                    .foregroundColor(theme.secondaryTextColor)
                    .tracking(3)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer()

            Rectangle()
                .fill(theme.accentColor)
                .frame(height: 0.5)

            HStack {
                if !card.email.isEmpty {
                    Text(card.email)
                        .font(theme.fontStyle.detailFont(10))
                        .foregroundColor(theme.secondaryTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .allowsTightening(true)
                }
                Spacer()
                if !card.phone.isEmpty {
                    Text(card.phone)
                        .font(theme.fontStyle.detailFont(10))
                        .foregroundColor(theme.secondaryTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .allowsTightening(true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
