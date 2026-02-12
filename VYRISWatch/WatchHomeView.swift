import SwiftUI

// MARK: - Watch Home View — Stealth Mode
// Default: shows minimal active identity (name/title) but NOT QR.
// QR only revealed via intentional double-tap OR "Reveal" button.
// Crown switches between cards. Deep obsidian aesthetic.

struct WatchHomeView: View {
    @Environment(WatchConnectivityManager.self) private var connectivity
    @Binding var deepLinkToQR: Bool
    @State private var selectedIndex: Int = 0
    @State private var showQR = false
    @State private var showRevealButton = false

    var body: some View {
        Group {
            if connectivity.cards.isEmpty {
                emptyState
            } else {
                stealthCardView
            }
        }
        .onChange(of: deepLinkToQR) { _, shouldOpen in
            if shouldOpen && !connectivity.cards.isEmpty {
                showQR = true
                deepLinkToQR = false
            }
        }
    }

    // MARK: - Empty State

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

    // MARK: - Stealth Card View

    private var stealthCardView: some View {
        let card = connectivity.cards[safe: selectedIndex] ?? connectivity.cards[0]
        return VStack(spacing: 4) {
            Spacer()

            // Minimal VYRIS mark
            Text("VYRIS")
                .font(.system(size: 9, weight: .light, design: .serif))
                .tracking(2)
                .foregroundColor(.secondary.opacity(0.6))

            Spacer().frame(height: 8)

            // Name — primary identity
            Text(card.fullName)
                .font(.system(size: 17, weight: .medium, design: .serif))
                .lineLimit(2)
                .minimumScaleFactor(0.6)
                .multilineTextAlignment(.center)

            // Title
            if !card.title.isEmpty {
                Text(card.title)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            // Company
            if !card.company.isEmpty {
                Text(card.company)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.accentColor.opacity(0.8))
                    .lineLimit(1)
            }

            Spacer()

            // Reveal action
            Button {
                showQR = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "qrcode")
                        .font(.system(size: 11, weight: .light))
                    Text("watch.reveal")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(1)
                }
                .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)

            // Card count indicator
            if connectivity.cards.count > 1 {
                HStack(spacing: 4) {
                    ForEach(0..<connectivity.cards.count, id: \.self) { i in
                        Circle()
                            .fill(i == selectedIndex ? Color.accentColor : Color.secondary.opacity(0.3))
                            .frame(width: 3, height: 3)
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 4)
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
