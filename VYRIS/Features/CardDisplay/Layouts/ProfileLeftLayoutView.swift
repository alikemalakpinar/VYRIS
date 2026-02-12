import SwiftUI

struct ProfileLeftLayoutView: View {
    let card: BusinessCard
    let theme: CardTheme

    private var initials: String {
        let parts = card.fullName.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }.map(String.init)
        return letters.joined()
    }

    var body: some View {
        HStack(alignment: .center, spacing: VYRISSpacing.md) {
            if let photo = card.photoImage {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(theme.accentColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(initials)
                            .font(theme.fontStyle.nameFont(16))
                            .foregroundColor(theme.accentColor)
                    )
            }

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
                }
            }

            Spacer()
        }
        .frame(maxHeight: .infinity)
        .overlay(alignment: .bottomTrailing) {
            VStack(alignment: .trailing, spacing: VYRISSpacing.xxs) {
                if !card.email.isEmpty {
                    Text(card.email)
                        .font(theme.fontStyle.detailFont(10))
                        .foregroundColor(theme.secondaryTextColor)
                }

                if !card.phone.isEmpty {
                    Text(card.phone)
                        .font(theme.fontStyle.detailFont(10))
                        .foregroundColor(theme.secondaryTextColor)
                }
            }
        }
    }
}
