import SwiftUI

// MARK: - Card Decorations
// Decorative overlay elements drawn on top of the card background.

struct CardDecorationView: View {
    let style: DecorationStyle
    let accentColor: Color
    let secondaryColor: Color

    var body: some View {
        GeometryReader { geo in
            let s = geo.size
            switch style {
            case .none:
                EmptyView()
            case .cornerLines:
                cornerLines(in: s)
            case .borderAccent:
                borderAccent(in: s)
            case .diagonalSlash:
                diagonalSlash(in: s)
            case .circuitLines:
                circuitLines(in: s)
            case .cornerBadge:
                cornerBadge(in: s)
            case .dotGrid:
                dotGrid(in: s)
            case .concentricCircles:
                concentricCircles(in: s)
            case .geometricFrame:
                geometricFrame(in: s)
            case .accentBar:
                accentBar(in: s)
            case .wavePattern:
                wavePattern(in: s)
            case .diamondGrid:
                diamondGrid(in: s)
            }
        }
        .allowsHitTesting(false)
    }

    private func cornerLines(in size: CGSize) -> some View {
        let len: CGFloat = 30, off: CGFloat = 16
        return ZStack {
            Path { p in
                p.move(to: CGPoint(x: off, y: off + len))
                p.addLine(to: CGPoint(x: off, y: off))
                p.addLine(to: CGPoint(x: off + len, y: off))
            }.stroke(accentColor.opacity(0.6), lineWidth: 1.5)
            Path { p in
                p.move(to: CGPoint(x: size.width - off - len, y: size.height - off))
                p.addLine(to: CGPoint(x: size.width - off, y: size.height - off))
                p.addLine(to: CGPoint(x: size.width - off, y: size.height - off - len))
            }.stroke(accentColor.opacity(0.6), lineWidth: 1.5)
        }
    }

    private func borderAccent(in size: CGSize) -> some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2).fill(accentColor)
                .frame(width: 4).padding(.vertical, 12)
            Spacer()
        }
    }

    private func diagonalSlash(in size: CGSize) -> some View {
        Path { p in
            p.move(to: CGPoint(x: size.width * 0.65, y: 0))
            p.addLine(to: CGPoint(x: size.width * 0.45, y: size.height))
        }.stroke(accentColor.opacity(0.12), lineWidth: 40)
    }

    private func circuitLines(in size: CGSize) -> some View {
        ZStack {
            Path { p in
                p.move(to: CGPoint(x: 0, y: size.height * 0.3))
                p.addLine(to: CGPoint(x: size.width * 0.2, y: size.height * 0.3))
                p.addLine(to: CGPoint(x: size.width * 0.25, y: size.height * 0.4))
                p.addLine(to: CGPoint(x: size.width * 0.4, y: size.height * 0.4))
            }.stroke(accentColor.opacity(0.15), lineWidth: 1.5)
            Path { p in
                p.move(to: CGPoint(x: size.width, y: size.height * 0.7))
                p.addLine(to: CGPoint(x: size.width * 0.75, y: size.height * 0.7))
                p.addLine(to: CGPoint(x: size.width * 0.7, y: size.height * 0.6))
                p.addLine(to: CGPoint(x: size.width * 0.55, y: size.height * 0.6))
            }.stroke(accentColor.opacity(0.15), lineWidth: 1.5)
            Circle().fill(accentColor.opacity(0.25)).frame(width: 5, height: 5)
                .position(x: size.width * 0.4, y: size.height * 0.4)
            Circle().fill(accentColor.opacity(0.25)).frame(width: 5, height: 5)
                .position(x: size.width * 0.55, y: size.height * 0.6)
            Circle().fill(accentColor.opacity(0.2)).frame(width: 3, height: 3)
                .position(x: size.width * 0.25, y: size.height * 0.4)
            Circle().fill(accentColor.opacity(0.2)).frame(width: 3, height: 3)
                .position(x: size.width * 0.7, y: size.height * 0.6)
        }
    }

    private func cornerBadge(in size: CGSize) -> some View {
        VStack {
            HStack {
                Spacer()
                Path { p in
                    p.move(to: .zero)
                    p.addLine(to: CGPoint(x: 60, y: 0))
                    p.addLine(to: CGPoint(x: 0, y: 60))
                    p.closeSubpath()
                }.fill(accentColor.opacity(0.15)).frame(width: 60, height: 60)
            }
            Spacer()
        }
    }

    private func dotGrid(in size: CGSize) -> some View {
        Canvas { ctx, cs in
            let sp: CGFloat = 20, ds: CGFloat = 1.5
            for x in stride(from: sp, through: cs.width - sp, by: sp) {
                for y in stride(from: sp, through: cs.height - sp, by: sp) {
                    ctx.fill(Path(ellipseIn: CGRect(x: x - ds / 2, y: y - ds / 2, width: ds, height: ds)),
                             with: .color(accentColor.opacity(0.08)))
                }
            }
        }
    }

    private func concentricCircles(in size: CGSize) -> some View {
        ZStack {
            ForEach(1..<4, id: \.self) { i in
                Circle()
                    .stroke(accentColor.opacity(Double(4 - i) * 0.04), lineWidth: 1)
                    .frame(width: CGFloat(i) * 60, height: CGFloat(i) * 60)
                    .position(x: size.width * 0.85, y: size.height * 0.2)
            }
        }
    }

    private func geometricFrame(in size: CGSize) -> some View {
        RoundedRectangle(cornerRadius: VYRISCardDimensions.cornerRadius - 4)
            .strokeBorder(accentColor.opacity(0.15), lineWidth: 1)
            .padding(10)
    }

    private func accentBar(in size: CGSize) -> some View {
        VStack { Rectangle().fill(accentColor).frame(height: 4); Spacer() }
            .clipShape(RoundedRectangle(cornerRadius: VYRISCardDimensions.cornerRadius))
    }

    private func wavePattern(in size: CGSize) -> some View {
        Path { p in
            p.move(to: CGPoint(x: 0, y: size.height * 0.8))
            p.addCurve(to: CGPoint(x: size.width, y: size.height * 0.75),
                       control1: CGPoint(x: size.width * 0.3, y: size.height * 0.65),
                       control2: CGPoint(x: size.width * 0.7, y: size.height * 0.9))
            p.addLine(to: CGPoint(x: size.width, y: size.height))
            p.addLine(to: CGPoint(x: 0, y: size.height))
            p.closeSubpath()
        }.fill(accentColor.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: VYRISCardDimensions.cornerRadius))
    }

    private func diamondGrid(in size: CGSize) -> some View {
        Canvas { ctx, cs in
            let sp: CGFloat = 24, ds: CGFloat = 6
            for x in stride(from: CGFloat(0), through: cs.width, by: sp) {
                for y in stride(from: CGFloat(0), through: cs.height, by: sp) {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: y - ds / 2))
                    path.addLine(to: CGPoint(x: x + ds / 2, y: y))
                    path.addLine(to: CGPoint(x: x, y: y + ds / 2))
                    path.addLine(to: CGPoint(x: x - ds / 2, y: y))
                    path.closeSubpath()
                    ctx.stroke(path, with: .color(accentColor.opacity(0.06)), lineWidth: 0.5)
                }
            }
        }
    }
}

// MARK: - Card Background Renderer

struct CardBackgroundRenderer: View {
    let theme: CardTheme

    var body: some View {
        Group {
            switch theme.backgroundStyle {
            case .solid:
                theme.backgroundColor
            case .gradient:
                LinearGradient(
                    colors: [theme.backgroundColor, theme.secondaryBackgroundColor ?? theme.backgroundColor.opacity(0.8)],
                    startPoint: .top, endPoint: .bottom)
            case .horizontalGradient:
                LinearGradient(
                    colors: [theme.backgroundColor, theme.secondaryBackgroundColor ?? theme.accentColor.opacity(0.2)],
                    startPoint: .leading, endPoint: .trailing)
            case .diagonalGradient:
                LinearGradient(
                    colors: [theme.backgroundColor, theme.secondaryBackgroundColor ?? theme.accentColor.opacity(0.15)],
                    startPoint: .topLeading, endPoint: .bottomTrailing)
            case .radialGlow:
                ZStack {
                    theme.backgroundColor
                    RadialGradient(colors: [theme.accentColor.opacity(0.08), .clear],
                                   center: .center, startRadius: 20, endRadius: 200)
                }
            case .dualTone:
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        theme.backgroundColor.frame(height: geo.size.height * 0.55)
                        (theme.secondaryBackgroundColor ?? theme.accentColor).frame(height: geo.size.height * 0.45)
                    }
                }
            }
        }
    }
}
