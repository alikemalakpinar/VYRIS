import SwiftUI

// MARK: - Conditional Modifier

extension View {

    /// Apply a modifier conditionally.
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Apply a modifier conditionally with an else clause.
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        then trueTransform: (Self) -> TrueContent,
        else falseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            falseTransform(self)
        }
    }
}

// MARK: - Card Shape

struct VYRISCardShape: Shape {
    var cornerRadius: CGFloat = VYRISCardDimensions.cornerRadius

    func path(in rect: CGRect) -> Path {
        Path(roundedRect: rect, cornerRadius: cornerRadius)
    }
}

// MARK: - Haptic Feedback

enum VYRISHaptics {

    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func soft() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    static func rigid() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Double-tap haptic pattern: rigid + soft echo
    static func issuance() {
        rigid()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            soft()
        }
    }
}
