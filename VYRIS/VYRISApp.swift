import SwiftUI
import SwiftData

// MARK: - VYRIS App Entry Point

@main
struct VYRISApp: App {
    @State private var settings = AppSettings()
    @State private var localization = LocalizationManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(settings)
                .environment(localization)
                .preferredColorScheme(settings.colorScheme)
                .environment(\.layoutDirection, localization.layoutDirection)
        }
        .modelContainer(for: BusinessCard.self)
    }
}

// MARK: - Root View (Navigation Controller)
// Handles onboarding → home routing.

struct RootView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(LocalizationManager.self) private var localization
    @State private var showSettings = false

    var body: some View {
        Group {
            if settings.hasCompletedOnboarding {
                mainContent
            } else {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        settings.hasCompletedOnboarding = true
                    }
                }
            }
        }
    }

    private var mainContent: some View {
        NavigationStack {
            HomeView(settings: settings, localization: localization)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(VYRISColors.Semantic.textSecondary)
                        }
                    }
                }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(settings: settings, localization: localization)
        }
    }
}
