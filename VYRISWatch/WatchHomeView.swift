import SwiftUI

// MARK: - Watch Home View
// Luxury-minimal card display with Digital Crown navigation.
// Tap shows full-screen QR code.

struct WatchHomeView: View {
    @Environment(WatchConnectivityManager.self) private var connectivity
    @Binding var deepLinkToQR: Bool
    @State private var selectedIndex: Int = 0
    @State private var showQR = false

    var body: some View {
        Group {
            if connectivity.cards.isEmpty {
                emptyState
            } else {
                cardView
            }
        }
        .onChange(of: deepLinkToQR) { _, shouldOpen in
            if shouldOpen && !connectivity.cards.isEmpty {
                showQR = true
                deepLinkToQR = false
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("VYRIS")
                .font(.system(size: 14, weight: .light, design: .serif))
                .tracking(3)
            Text("watch.noCards")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var cardView: some View {
        let card = connectivity.cards[safe: selectedIndex] ?? connectivity.cards[0]
        return VStack(spacing: 6) {
            Spacer()

            Text("VYRIS")
                .font(.system(size: 10, weight: .light, design: .serif))
                .tracking(2)
                .foregroundColor(.secondary)

            Text(card.fullName)
                .font(.system(size: 16, weight: .medium, design: .serif))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if !card.title.isEmpty {
                Text(card.title)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            if !card.company.isEmpty {
                Text(card.company)
                    .font(.system(size: 10))
                    .foregroundColor(.accentColor)
                    .lineLimit(1)
            }

            Spacer()

            // Card count indicator
            if connectivity.cards.count > 1 {
                HStack(spacing: 4) {
                    ForEach(0..<connectivity.cards.count, id: \.self) { i in
                        Circle()
                            .fill(i == selectedIndex ? Color.accentColor : Color.secondary.opacity(0.3))
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .focusable()
        .digitalCrownRotation(
            Binding(
                get: { Double(selectedIndex) },
                set: { newValue in
                    let clamped = max(0, min(Int(newValue.rounded()), connectivity.cards.count - 1))
                    if clamped != selectedIndex {
                        selectedIndex = clamped
                        connectivity.setActiveCard(id: connectivity.cards[clamped].id)
                    }
                }
            ),
            from: 0,
            through: Double(max(0, connectivity.cards.count - 1)),
            by: 1,
            sensitivity: .medium
        )
        .onTapGesture {
            showQR = true
        }
        .fullScreenCover(isPresented: $showQR) {
            WatchQRView(card: card)
        }
        .onAppear {
            if let activeId = connectivity.activeCardId,
               let idx = connectivity.cards.firstIndex(where: { $0.id == activeId }) {
                selectedIndex = idx
            }
        }
    }
}

// MARK: - Safe Array Subscript

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
