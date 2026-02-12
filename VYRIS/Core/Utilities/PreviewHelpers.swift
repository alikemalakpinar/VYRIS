import SwiftUI
import SwiftData

// MARK: - Preview Helpers
// Convenience utilities for SwiftUI previews.

struct PreviewContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .modelContainer(for: BusinessCard.self, inMemory: true)
    }
}

// MARK: - Preview Modifiers

extension View {
    func vyrisPreview() -> some View {
        self
            .modelContainer(for: BusinessCard.self, inMemory: true)
            .environment(AppSettings())
            .environment(LocalizationManager())
    }
}
