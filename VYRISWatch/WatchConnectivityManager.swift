import Foundation
import WatchConnectivity

// MARK: - Watch Connectivity Manager (watchOS side)
// Receives card data from the iOS app.

@Observable
final class WatchConnectivityManager: NSObject {
    var cards: [WatchCardData] = []
    var activeCardId: UUID?

    var activeCard: WatchCardData? {
        if let activeCardId, let card = cards.first(where: { $0.id == activeCardId }) {
            return card
        }
        return cards.first
    }

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func setActiveCard(id: UUID) {
        guard cards.contains(where: { $0.id == id }) else { return }
        activeCardId = id
    }

    private func processPayload(_ data: Data) {
        guard let payload = try? JSONDecoder().decode(WatchSyncPayload.self, from: data) else { return }
        DispatchQueue.main.async {
            self.cards = payload.cards
            self.activeCardId = payload.activeCardId
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        // Load any existing application context
        if let data = session.receivedApplicationContext[WatchSyncPayload.messageKey] as? Data {
            processPayload(data)
        }
    }

    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        if let data = applicationContext[WatchSyncPayload.messageKey] as? Data {
            processPayload(data)
        }
    }
}
