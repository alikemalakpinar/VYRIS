import SwiftUI

struct MinimalLayoutView: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack {
            Spacer()

            Text(card.fullName)
                .font(theme.fontStyle.nameFont(28))
                .foregroundColor(theme.textColor)
                .tracking(2)
                .multilineTextAlignment(.center)

            if !card.title.isEmpty {
                Text(card.title)
                    .font(theme.fontStyle.detailFont(11))
                    .foregroundColor(theme.secondaryTextColor)
                    .tracking(3)
                    .textCase(.uppercase)
                    .padding(.top, VYRISSpacing.xs)
            }

            Spacer()
        }
    }
}
