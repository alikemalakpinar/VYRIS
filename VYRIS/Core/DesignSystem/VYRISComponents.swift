import SwiftUI

// MARK: - Background System

struct VYRISBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            VYRISColors.Semantic.backgroundPrimary
                .ignoresSafeArea()

            // Ultra-subtle noise texture
            NoiseTextureView()
                .opacity(colorScheme == .dark ? 0.03 : 0.04)
                .ignoresSafeArea()

            // Soft radial depth behind card area
            RadialGradient(
                gradient: Gradient(colors: [
                    VYRISColors.Semantic.accent.opacity(0.03),
                    Color.clear
                ]),
                center: .center,
                startRadius: 50,
                endRadius: 300
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Noise Texture

struct NoiseTextureView: View {

    var body: some View {
        Canvas { context, size in
            for _ in 0..<Int(size.width * size.height * 0.02) {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let opacity = Double.random(in: 0.02...0.08)

                context.fill(
                    Path(CGRect(x: x, y: y, width: 1, height: 1)),
                    with: .color(.gray.opacity(opacity))
                )
            }
        }
    }
}

// MARK: - Shadow System

enum VYRISShadow {

    struct Properties {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }

    static let cardResting = Properties(
        color: VYRISColors.Semantic.shadow,
        radius: 16,
        x: 0,
        y: 8
    )

    static let cardElevated = Properties(
        color: VYRISColors.Semantic.shadow,
        radius: 24,
        x: 0,
        y: 12
    )

    static let subtle = Properties(
        color: VYRISColors.Semantic.shadow,
        radius: 8,
        x: 0,
        y: 4
    )
}

extension View {
    func vyrisShadow(_ shadow: VYRISShadow.Properties) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}

// MARK: - Action Button

struct VYRISActionButton: View {
    let title: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(VYRISTypography.button())
                .foregroundColor(VYRISColors.Semantic.textPrimary)
                .tracking(1.2)
                .textCase(.uppercase)
                .padding(.horizontal, VYRISSpacing.md)
                .padding(.vertical, VYRISSpacing.xs)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Divider

struct VYRISDivider: View {
    var body: some View {
        Rectangle()
            .fill(VYRISColors.Semantic.stroke)
            .frame(height: 0.5)
    }
}

// MARK: - Brand Mark

struct VYRISBrandMark: View {
    var size: CGFloat = 18

    var body: some View {
        Text("VYRIS")
            .font(VYRISTypography.brandMark(size: size))
            .foregroundColor(VYRISColors.Semantic.textPrimary)
            .tracking(4)
    }
}
