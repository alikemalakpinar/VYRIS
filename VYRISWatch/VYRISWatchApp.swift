import SwiftUI

// MARK: - VYRIS Watch App Entry Point

@main
struct VYRISWatchApp: App {
    @State private var connectivityManager = WatchConnectivityManager()

    var body: some Scene {
        WindowGroup {
            WatchHomeView()
                .environment(connectivityManager)
        }
    }
}
