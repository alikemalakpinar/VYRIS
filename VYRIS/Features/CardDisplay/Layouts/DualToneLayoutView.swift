import SwiftUI

struct DualToneLayoutView: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                VStack {
                    Spacer()
                    Text(card.fullName)
                        .font(theme.fontStyle.nameFont(24))
                        .foregroundColor(theme.textColor)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height / 2)

                ZStack {
                    theme.accentColor

                    VStack(spacing: VYRISSpacing.xxs) {
                        if !card.title.isEmpty {
                            Text(card.title)
                                .font(theme.fontStyle.titleFont(13))
                                .foregroundColor(.white)
                        }

                        if !card.company.isEmpty {
                            Text(card.company)
                                .font(theme.fontStyle.titleFont(11))
                                .foregroundColor(.white.opacity(0.85))
                        }

                        if !card.email.isEmpty {
                            Text(card.email)
                                .font(theme.fontStyle.detailFont(10))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.top, VYRISSpacing.xxs)
                        }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height / 2)
            }
        }
    }
}
