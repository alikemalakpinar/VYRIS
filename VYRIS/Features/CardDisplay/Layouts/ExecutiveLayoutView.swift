import SwiftUI

struct ExecutiveLayoutView: View {
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

            HStack(spacing: VYRISSpacing.sm) {
                Rectangle().fill(theme.accentColor).frame(width: 20, height: 0.5)
                if !card.title.isEmpty {
                    Text(card.title)
                        .font(theme.fontStyle.detailFont(11))
                        .foregroundColor(theme.secondaryTextColor)
                        .tracking(1)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Rectangle().fill(theme.accentColor).frame(width: 20, height: 0.5)
            }

            if !card.company.isEmpty {
                Text(card.company)
                    .font(theme.fontStyle.titleFont(12))
                    .foregroundColor(theme.accentColor)
                    .tracking(2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer()
        }
    }
}
