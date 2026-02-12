import SwiftUI

struct MagazineLayoutView: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(alignment: .leading, spacing: VYRISSpacing.xs) {
            Text(card.fullName)
                .font(theme.fontStyle.nameFont(26))
                .foregroundColor(theme.textColor)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Rectangle()
                .fill(theme.accentColor)
                .frame(height: 1)

            HStack(spacing: VYRISSpacing.xs) {
                if !card.title.isEmpty {
                    Text(card.title)
                        .font(theme.fontStyle.titleFont(12))
                        .foregroundColor(theme.secondaryTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                if !card.title.isEmpty && !card.company.isEmpty {
                    Text("·")
                        .font(theme.fontStyle.titleFont(12))
                        .foregroundColor(theme.secondaryTextColor)
                }

                if !card.company.isEmpty {
                    Text(card.company)
                        .font(theme.fontStyle.titleFont(12))
                        .foregroundColor(theme.accentColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }

            if !card.bio.isEmpty {
                Text(card.bio)
                    .font(theme.fontStyle.detailFont(9))
                    .foregroundColor(theme.secondaryTextColor)
                    .lineLimit(3)
            }

            Spacer()

            if !card.location.isEmpty {
                HStack(spacing: VYRISSpacing.xxs) {
                    Image(systemName: "mappin")
                        .font(.system(size: 8))
                        .foregroundColor(theme.accentColor)

                    Text(card.location)
                        .font(theme.fontStyle.detailFont(9))
                        .foregroundColor(theme.secondaryTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
