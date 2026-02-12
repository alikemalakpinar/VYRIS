import SwiftUI

// MARK: - VYRIS Watch App Entry Point

@main
struct VYRISWatchApp: App {
    @State private var connectivityManager = WatchConnectivityManager()
    @State private var deepLinkToQR = false

    var body: some Scene {
        WindowGroup {
            WatchHomeView(deepLinkToQR: $deepLinkToQR)
                .environment(connectivityManager)
                .onOpenURL { url in
                    if url.scheme == "vyris", url.host == "watch", url.path == "/qr" {
                        deepLinkToQR = true
                    }
                }
        }
    }
}
