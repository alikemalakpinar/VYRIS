import SwiftUI

struct PhotoHeroLayoutView: View {
    let card: BusinessCard
    let theme: CardTheme

    private var initials: String {
        let parts = card.fullName.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }.map(String.init)
        return letters.joined()
    }

    var body: some View {
        VStack(spacing: VYRISSpacing.xs) {
            if let photo = card.photoImage {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(theme.accentColor)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(initials)
                            .font(theme.fontStyle.nameFont(20))
                            .foregroundColor(.white)
                    )
            }

            Text(card.fullName)
                .font(theme.fontStyle.nameFont(20))
                .foregroundColor(theme.textColor)
                .multilineTextAlignment(.center)

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

            Spacer()

            if !card.email.isEmpty {
                Text(card.email)
                    .font(theme.fontStyle.detailFont(10))
                    .foregroundColor(theme.secondaryTextColor)
            }
        }
    }
}
