import SwiftUI

// MARK: - Card Flip View
// Deliberate 3D flip ritual: heavy easing (0.7s), rigid haptic.
// Back side is always static (no tilt). Front gets parallax.

struct CardFlipView: View {
    let card: BusinessCard
    let theme: CardTheme
    let motionEnabled: Bool
    let tiltX: Double
    let tiltY: Double

    @State private var isFlipped = false
    @State private var flipDegrees: Double = 0

    var body: some View {
        ZStack {
            CardFrontView(
                card: card,
                theme: theme,
                tiltX: isFlipped ? 0 : tiltX,
                tiltY: isFlipped ? 0 : tiltY,
                motionEnabled: motionEnabled && !isFlipped
            )
            .opacity(flipDegrees < 90 ? 1 : 0)

            CardBackView(card: card, theme: theme)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(flipDegrees >= 90 ? 1 : 0)
        }
        .rotation3DEffect(
            .degrees(flipDegrees),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.5
        )
        .rotation3DEffect(.degrees(isFlipped ? 0 : tiltX), axis: (x: 1, y: 0, z: 0))
        .rotation3DEffect(.degrees(isFlipped ? 0 : tiltY), axis: (x: 0, y: 1, z: 0))
        .vyrisShadow(isFlipped ? VYRISShadow.subtle : VYRISShadow.cardResting)
        .onTapGesture { performFlip() }
    }

    private func performFlip() {
        VYRISHaptics.rigid()
        withAnimation(.easeInOut(duration: 0.7)) { flipDegrees += 180 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { isFlipped.toggle() }
    }
}

// MARK: - Standalone Card Container with Motion
// Uses resolvedTheme() for custom theme support.
// 3-layer parallax: background 1x, material 1.5x (via tilt on container), text 2x (inside CardFrontView).

struct CardDisplayContainer: View {
    @Environment(MotionManager.self) private var motionManager
    let card: BusinessCard
    let motionEnabled: Bool

    @State private var isFlipped = false
    @State private var flipDegrees: Double = 0

    private var theme: CardTheme {
        card.resolvedTheme()
    }

    var body: some View {
        ZStack {
            CardFrontView(
                card: card,
                theme: theme,
                tiltX: isFlipped ? 0 : motionManager.pitch,
                tiltY: isFlipped ? 0 : motionManager.roll,
                motionEnabled: motionEnabled && !isFlipped
            )
            .opacity(flipDegrees.truncatingRemainder(dividingBy: 360) < 90
                     || flipDegrees.truncatingRemainder(dividingBy: 360) > 270 ? 1 : 0)

            CardBackView(card: card, theme: theme)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(flipDegrees.truncatingRemainder(dividingBy: 360) >= 90
                         && flipDegrees.truncatingRemainder(dividingBy: 360) <= 270 ? 1 : 0)
        }
        .rotation3DEffect(.degrees(flipDegrees), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
        .if(motionEnabled && !isFlipped) { view in
            view
                .rotation3DEffect(.degrees(motionManager.backgroundPitch), axis: (x: 1, y: 0, z: 0))
                .rotation3DEffect(.degrees(motionManager.backgroundRoll), axis: (x: 0, y: 1, z: 0))
        }
        .vyrisShadow(isFlipped ? VYRISShadow.subtle : VYRISShadow.cardResting)
        .onTapGesture { performFlip() }
    }

    private func performFlip() {
        VYRISHaptics.rigid()
        withAnimation(.easeInOut(duration: 0.7)) { flipDegrees += 180 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { isFlipped.toggle() }
    }
}

#Preview {
    CardFlipView(
        card: .sample,
        theme: ThemeRegistry.ivoryClassic,
        motionEnabled: false,
        tiltX: 0, tiltY: 0
    )
    .padding(VYRISSpacing.lg)
}
