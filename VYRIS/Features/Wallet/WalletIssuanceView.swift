import SwiftUI
import PassKit
import Contacts

// MARK: - Wallet Issuance View
// "Issue to Wallet" — minting feel animation before presenting system Wallet sheet.
// Card scales down, slides into a slot, VYRIS seal stamp, then PassKit add.

struct WalletIssuanceView: View {
    let card: BusinessCard
    @Environment(\.dismiss) private var dismiss

    @State private var phase: IssuancePhase = .idle
    @State private var passError: String?

    enum IssuancePhase {
        case idle
        case animatingSlot   // Card scales down + slides
        case sealStamp       // VYRIS seal glow
        case presenting      // System PKAddPassesViewController
        case completed
    }

    var body: some View {
        ZStack {
            VaultBackground()

            VStack(spacing: VYRISSpacing.xl) {
                Spacer()

                // Card visualization
                cardVisualization

                // Status text
                statusText

                Spacer()

                if phase == .idle {
                    issueButton
                        .padding(.bottom, VYRISSpacing.xxl)
                }

                if phase == .completed {
                    Button { dismiss() } label: {
                        Text("common.done")
                            .font(VYRISTypography.button())
                            .foregroundColor(VYRISColors.Vault.champagne)
                            .tracking(1.5)
                            .textCase(.uppercase)
                    }
                    .padding(.bottom, VYRISSpacing.xxl)
                }
            }
        }
        .alert("common.error", isPresented: .init(
            get: { passError != nil },
            set: { if !$0 { passError = nil } }
        )) {
            Button("common.done") { passError = nil }
        } message: {
            if let error = passError {
                Text(error)
            }
        }
    }

    // MARK: - Card Visualization

    private var cardVisualization: some View {
        let theme = card.resolvedTheme()
        return ZStack {
            // Slot/receptacle
            if phase != .idle {
                RoundedRectangle(cornerRadius: 4)
                    .fill(VYRISColors.Vault.obsidianElevated)
                    .frame(width: 200, height: 130)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(VYRISColors.Vault.champagne.opacity(0.1), lineWidth: 0.5)
                    )
            }

            // Card
            CardFrontView(
                card: card,
                theme: theme,
                tiltX: 0, tiltY: 0,
                motionEnabled: false
            )
            .frame(width: cardWidth, height: cardWidth / VYRISCardDimensions.aspectRatio)
            .scaleEffect(cardScale)
            .offset(y: cardOffsetY)
            .opacity(cardOpacity)

            // Seal stamp glow
            if phase == .sealStamp || phase == .completed {
                sealStamp
            }
        }
        .frame(height: 250)
    }

    private var cardWidth: CGFloat {
        switch phase {
        case .idle: return 300
        case .animatingSlot, .sealStamp, .presenting, .completed: return 180
        }
    }

    private var cardScale: CGFloat {
        switch phase {
        case .idle: return 1.0
        case .animatingSlot: return 0.6
        case .sealStamp: return 0.6
        case .presenting: return 0.55
        case .completed: return 0.6
        }
    }

    private var cardOffsetY: CGFloat {
        switch phase {
        case .idle: return 0
        case .animatingSlot: return 10
        case .sealStamp, .presenting, .completed: return 0
        }
    }

    private var cardOpacity: Double {
        switch phase {
        case .idle: return 1.0
        case .animatingSlot: return 0.9
        case .sealStamp: return 0.8
        case .presenting: return 0.7
        case .completed: return 1.0
        }
    }

    // MARK: - Seal Stamp

    private var sealStamp: some View {
        ZStack {
            // Glow ring
            Circle()
                .strokeBorder(VYRISColors.Vault.champagne.opacity(0.4), lineWidth: 1)
                .frame(width: 60, height: 60)
                .scaleEffect(phase == .completed ? 1.2 : 0.8)
                .opacity(phase == .completed ? 0.6 : 1.0)

            // VYRIS mark
            Text("V")
                .font(.system(size: 18, weight: .light, design: .serif))
                .foregroundColor(VYRISColors.Vault.champagne)
        }
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Status Text

    private var statusText: some View {
        Group {
            switch phase {
            case .idle:
                Text("wallet.readyToIssue")
                    .font(VYRISTypography.meta())
                    .foregroundColor(VYRISColors.Vault.textOnDarkSecondary)
                    .tracking(1)
            case .animatingSlot:
                Text("wallet.preparing")
                    .font(VYRISTypography.meta())
                    .foregroundColor(VYRISColors.Vault.textOnDarkSecondary)
                    .tracking(1)
            case .sealStamp:
                Text("wallet.certifying")
                    .font(VYRISTypography.meta())
                    .foregroundColor(VYRISColors.Vault.champagne)
                    .tracking(1)
            case .presenting:
                Text("wallet.issuing")
                    .font(VYRISTypography.meta())
                    .foregroundColor(VYRISColors.Vault.champagne)
                    .tracking(1)
            case .completed:
                Text("wallet.issued")
                    .font(VYRISTypography.meta())
                    .foregroundColor(VYRISColors.Vault.champagne)
                    .tracking(2)
                    .textCase(.uppercase)
            }
        }
    }

    // MARK: - Issue Button

    private var issueButton: some View {
        Button {
            beginIssuance()
        } label: {
            Text("wallet.issueToWallet")
                .font(VYRISTypography.button())
                .foregroundColor(VYRISColors.Vault.obsidian)
                .tracking(1.5)
                .textCase(.uppercase)
                .padding(.horizontal, VYRISSpacing.xl)
                .padding(.vertical, VYRISSpacing.sm)
                .background(
                    Capsule()
                        .fill(VYRISColors.Vault.champagne)
                )
        }
    }

    // MARK: - Issuance Sequence

    private func beginIssuance() {
        // Phase 1: Animate card into slot
        VYRISHaptics.rigid()
        withAnimation(.easeOut(duration: 0.6)) {
            phase = .animatingSlot
        }

        // Phase 2: Seal stamp
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            VYRISHaptics.issuance()
            withAnimation(.easeOut(duration: 0.4)) {
                phase = .sealStamp
            }
        }

        // Phase 3: Add to Wallet via Contacts framework
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeOut(duration: 0.3)) {
                phase = .presenting
            }
            addContactToDevice()
        }
    }

    /// Since PKPass requires a signed .pkpass file from a server,
    /// and VYRIS is offline-first, we use CNContactStore to add the
    /// contact directly — achieving the "official issuance" feel
    /// while staying fully offline.
    private func addContactToDevice() {
        let store = CNContactStore()

        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    let contact = CNMutableContact()
                    contact.givenName = card.fullName.components(separatedBy: " ").first ?? card.fullName
                    contact.familyName = card.fullName.components(separatedBy: " ").dropFirst().joined(separator: " ")

                    if !card.title.isEmpty {
                        contact.jobTitle = card.title
                    }
                    if !card.company.isEmpty {
                        contact.organizationName = card.company
                    }
                    if !card.phone.isEmpty {
                        contact.phoneNumbers = [CNLabeledValue(
                            label: CNLabelWork,
                            value: CNPhoneNumber(stringValue: card.phone)
                        )]
                    }
                    if !card.email.isEmpty {
                        contact.emailAddresses = [CNLabeledValue(
                            label: CNLabelWork,
                            value: card.email as NSString
                        )]
                    }
                    if !card.website.isEmpty {
                        contact.urlAddresses = [CNLabeledValue(
                            label: CNLabelWork,
                            value: card.website as NSString
                        )]
                    }
                    contact.note = "Issued via VYRIS"

                    let saveRequest = CNSaveRequest()
                    saveRequest.add(contact, toContainerWithIdentifier: nil)

                    do {
                        try store.execute(saveRequest)
                        VYRISHaptics.success()
                        withAnimation(.easeOut(duration: 0.5)) {
                            phase = .completed
                        }
                    } catch {
                        passError = error.localizedDescription
                        withAnimation { phase = .idle }
                    }
                } else {
                    passError = NSLocalizedString("wallet.contactsPermission", comment: "")
                    withAnimation { phase = .idle }
                }
            }
        }
    }
}
