import SwiftUI

struct TechCardLayoutView: View {
    let card: BusinessCard
    let theme: CardTheme

    var body: some View {
        VStack(alignment: .leading, spacing: VYRISSpacing.xs) {
            Text("> \(card.fullName)")
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .foregroundColor(theme.textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            if !card.title.isEmpty {
                Text("// \(card.title)")
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundColor(theme.secondaryTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer()

            VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
                if !card.company.isEmpty {
                    Text("org: \(card.company)")
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundColor(theme.accentColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                if !card.email.isEmpty {
                    Text("mail: \(card.email)")
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundColor(theme.secondaryTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                if !card.phone.isEmpty {
                    Text("tel: \(card.phone)")
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundColor(theme.secondaryTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                if !card.website.isEmpty {
                    Text("web: \(card.website)")
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundColor(theme.secondaryTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
