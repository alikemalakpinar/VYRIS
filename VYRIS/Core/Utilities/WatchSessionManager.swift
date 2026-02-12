import Foundation
import WatchConnectivity

// MARK: - Watch Session Manager (iOS side)
// Sends card data to Apple Watch via WatchConnectivity.

@Observable
final class WatchSessionManager: NSObject {

    static let shared = WatchSessionManager()
    private var session: WCSession?

    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    /// Send current cards and active ID to the Watch.
    func syncCards(_ cards: [WatchCardData], activeCardId: UUID?) {
        guard let session, session.isPaired, session.isWatchAppInstalled else { return }
        let payload = WatchSyncPayload(cards: cards, activeCardId: activeCardId)
        guard let data = try? JSONEncoder().encode(payload) else { return }

        // Use application context for reliable delivery
        try? session.updateApplicationContext([
            WatchSyncPayload.messageKey: data
        ])
    }
}

// MARK: - WCSessionDelegate

extension WatchSessionManager: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}
