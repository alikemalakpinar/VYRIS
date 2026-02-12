import Foundation

// MARK: - Watch Card Data
// Lightweight card representation for WatchConnectivity transfer.
// No photos — keeps payload small for Watch transmission.

struct WatchCardData: Codable, Identifiable {
    let id: UUID
    let fullName: String
    let title: String
    let company: String
    let vCardString: String

    /// One-line summary for Watch display: "Name · Title"
    var summary: String {
        if !title.isEmpty {
            return "\(fullName) · \(title)"
        }
        return fullName
    }
}

// MARK: - Watch Sync Payload

struct WatchSyncPayload: Codable {
    let cards: [WatchCardData]
    let activeCardId: UUID?

    static let messageKey = "vyris_sync"
}
