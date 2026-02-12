import SwiftUI
import SwiftData

// MARK: - VYRIS App Entry Point

@main
struct VYRISApp: App {
    @State private var settings = AppSettings()
    @State private var localization = LocalizationManager()
    @State private var motionManager = MotionManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(settings)
                .environment(localization)
                .environment(motionManager)
                .preferredColorScheme(settings.colorScheme)
                .environment(\.layoutDirection, localization.layoutDirection)
        }
        .modelContainer(for: BusinessCard.self)
    }
}

// MARK: - Root View (Navigation Controller)
// Handles onboarding → vault routing.
// No visible chrome in vault mode — actions via two-finger long-press.

struct RootView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(LocalizationManager.self) private var localization

    var body: some View {
        Group {
            if settings.hasCompletedOnboarding {
                VaultHomeView(settings: settings, localization: localization)
            } else {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        settings.hasCompletedOnboarding = true
                    }
                }
            }
        }
    }
}
