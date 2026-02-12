import SwiftUI

struct BoldLayoutView: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(card.fullName)
                .font(theme.fontStyle.nameFont(30))
                .foregroundColor(theme.textColor)
                .minimumScaleFactor(0.7)

            Spacer()

            HStack(alignment: .bottom) {
                if !card.title.isEmpty {
                    Text(card.title.uppercased())
                        .font(theme.fontStyle.detailFont(10))
                        .foregroundColor(theme.secondaryTextColor)
                        .tracking(1.5)
                }
                Spacer()
                if !card.company.isEmpty {
                    Text(card.company)
                        .font(theme.fontStyle.detailFont(10))
                        .foregroundColor(theme.accentColor)
                        .tracking(1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
