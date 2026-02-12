import SwiftUI

// MARK: - Card Flip View
// 3D card flip with tilt reset before flip, haptic feedback,
// and smooth 0.6s animation.

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
            // Front face — visible when not flipped
            CardFrontView(
                card: card,
                theme: theme,
                tiltX: isFlipped ? 0 : tiltX,
                tiltY: isFlipped ? 0 : tiltY,
                motionEnabled: motionEnabled && !isFlipped
            )
            .opacity(flipDegrees < 90 ? 1 : 0)

            // Back face — visible when flipped
            CardBackView(card: card, theme: theme)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(flipDegrees >= 90 ? 1 : 0)
        }
        .rotation3DEffect(
            .degrees(flipDegrees),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.5
        )
        // Tilt effect only on front
        .rotation3DEffect(
            .degrees(isFlipped ? 0 : tiltX),
            axis: (x: 1, y: 0, z: 0)
        )
        .rotation3DEffect(
            .degrees(isFlipped ? 0 : tiltY),
            axis: (x: 0, y: 1, z: 0)
        )
        .vyrisShadow(isFlipped ? VYRISShadow.subtle : VYRISShadow.cardResting)
        .onTapGesture {
            performFlip()
        }
    }

    private func performFlip() {
        VYRISHaptics.soft()

        withAnimation(.easeInOut(duration: 0.6)) {
            flipDegrees += 180
        }

        // Toggle state at midpoint
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isFlipped.toggle()
        }
    }
}

// MARK: - Standalone Card Container with Motion

struct CardDisplayContainer: View {
    let card: BusinessCard
    let motionManager: MotionManager
    let motionEnabled: Bool

    @State private var isFlipped = false
    @State private var flipDegrees: Double = 0

    private var theme: CardTheme {
        ThemeRegistry.theme(for: card.themeId)
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
        .rotation3DEffect(
            .degrees(flipDegrees),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.5
        )
        .if(motionEnabled && !isFlipped) { view in
            view
                .rotation3DEffect(.degrees(motionManager.pitch), axis: (x: 1, y: 0, z: 0))
                .rotation3DEffect(.degrees(motionManager.roll), axis: (x: 0, y: 1, z: 0))
        }
        .vyrisShadow(isFlipped ? VYRISShadow.subtle : VYRISShadow.cardResting)
        .onTapGesture {
            performFlip()
        }
    }

    private func performFlip() {
        VYRISHaptics.soft()

        withAnimation(.easeInOut(duration: 0.6)) {
            flipDegrees += 180
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isFlipped.toggle()
        }
    }
}

// MARK: - Preview

#Preview {
    CardFlipView(
        card: .sample,
        theme: ThemeRegistry.ivoryClassic,
        motionEnabled: false,
        tiltX: 0,
        tiltY: 0
    )
    .padding(VYRISSpacing.lg)
}
