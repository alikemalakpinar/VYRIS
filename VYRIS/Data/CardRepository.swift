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
    var activeCardIndex: Int = 0

    var activeCard: BusinessCard? {
        guard !cards.isEmpty, activeCardIndex >= 0, activeCardIndex < cards.count else {
            return nil
        }
        return cards[activeCardIndex]
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
        activeCardIndex = cards.count - 1
    }

    func updateCard(_ card: BusinessCard) {
        card.updatedAt = Date()
        save()
        fetchCards()
    }

    func deleteCard(_ card: BusinessCard) {
        modelContext.delete(card)
        save()
        fetchCards()
        if activeCardIndex >= cards.count {
            activeCardIndex = max(0, cards.count - 1)
        }
    }

    func setActiveCard(at index: Int) {
        guard index >= 0, index < cards.count else { return }
        activeCardIndex = index
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
