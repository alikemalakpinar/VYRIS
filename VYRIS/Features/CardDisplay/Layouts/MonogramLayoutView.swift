import SwiftUI

struct MonogramLayoutView: View {
    let card: BusinessCard
    let theme: CardTheme

    private var monogram: String {
        let parts = card.fullName.split(separator: " ")
        let initials = parts.prefix(2).compactMap { $0.first }.map(String.init)
        return initials.joined()
    }

    var body: some View {
        HStack(spacing: VYRISSpacing.md) {
            Text(monogram)
                .font(.system(size: 48, weight: .ultraLight, design: .serif))
                .foregroundColor(theme.accentColor.opacity(0.3))

            VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
                Text(card.fullName)
                    .font(theme.fontStyle.nameFont(18))
                    .foregroundColor(theme.textColor)

                if !card.title.isEmpty {
                    Text(card.title)
                        .font(theme.fontStyle.titleFont(12))
                        .foregroundColor(theme.secondaryTextColor)
                }

                if !card.company.isEmpty {
                    Text(card.company)
                        .font(theme.fontStyle.titleFont(11))
                        .foregroundColor(theme.accentColor)
                        .padding(.top, VYRISSpacing.xxs)
                }
            }

            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
}
