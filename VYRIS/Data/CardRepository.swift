import Foundation
import SwiftData
import SwiftUI

// MARK: - Card Repository
// Single source of truth for all card operations.
// Offline-first: all data persisted locally via SwiftData.

@Observable
final class CardRepository {

    private var modelContext: ModelContext

    var cards: [BusinessCard] = []
    var activeCardId: UUID?

    var activeCard: BusinessCard? {
        if let activeCardId, let card = cards.first(where: { $0.id == activeCardId }) {
            return card
        }
        return cards.first
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchCards()
    }

    // MARK: - CRUD Operations

    func fetchCards() {
        let descriptor = FetchDescriptor<BusinessCard>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        cards = (try? modelContext.fetch(descriptor)) ?? []
    }

    func addCard(_ card: BusinessCard) {
        modelContext.insert(card)
        save()
        fetchCards()
        activeCardId = card.id
    }

    func updateCard(_ card: BusinessCard) {
        card.updatedAt = Date()
        save()
        fetchCards()
    }

    func deleteCard(_ card: BusinessCard) {
        let wasActive = activeCardId == card.id
        modelContext.delete(card)
        save()
        fetchCards()
        if wasActive {
            activeCardId = cards.first?.id
        }
    }

    func setActiveCard(id: UUID) {
        guard cards.contains(where: { $0.id == id }) else { return }
        activeCardId = id
    }

    // MARK: - Persistence

    private func save() {
        try? modelContext.save()
    }

    // MARK: - Seed Data

    func seedIfEmpty() {
        guard cards.isEmpty else { return }
        addCard(BusinessCard.sample)
    }
}
