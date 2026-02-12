import SwiftUI
import LocalAuthentication

// MARK: - Vault Home View
// "Obsidian Vault" — the card lives tucked in a sleeve.
// Pull up to reveal. Two-finger long-press for actions.
// During presentation: zero chrome, the card IS the interface.

struct VaultHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(MotionManager.self) private var motionManager

    @State private var repository: CardRepository?
    @State private var isVaultUnlocked = false
    @State private var sleeveOffset: CGFloat = 0
    @State private var isCardRevealed = false
    @State private var isFlipped = false
    @State private var flipDegrees: Double = 0
    @State private var showActionSheet = false
    @State private var showEditor = false
    @State private var showCommission = false
    @State private var showPresent = false
    @State private var showSettings = false
    @State private var showScanner = false
    @State private var editingCard: BusinessCard?
    @State private var dragOffset: CGFloat = 0

    let settings: AppSettings
    let localization: LocalizationManager

    // Sleeve reveals 10-15% of the card by default
    private let sleeveVisibleFraction: CGFloat = 0.12
    private let revealThreshold: CGFloat = 80

    var body: some View {
        Group {
            if let repository {
                if settings.vaultLockEnabled && !isVaultUnlocked {
                    vaultLockScreen(repository: repository)
                } else {
                    vaultContent(repository: repository)
                }
            } else {
                Color.clear.onAppear {
                    let repo = CardRepository(modelContext: modelContext)
                    repo.seedIfEmpty()
                    self.repository = repo
                    if !settings.vaultLockEnabled {
                        isVaultUnlocked = true
                    }
                }
            }
        }
        .onAppear {
            if settings.motionEnabled { motionManager.start() }
        }
        .onDisappear { motionManager.stop() }
        .onChange(of: settings.motionEnabled) { _, enabled in
            if enabled { motionManager.start() } else { motionManager.stop() }
        }
    }

    // MARK: - Vault Lock Screen

    private func vaultLockScreen(repository: CardRepository) -> some View {
        ZStack {
            VaultBackground()

            VStack(spacing: VYRISSpacing.xl) {
                Spacer()

                VYRISBrandMark(size: 14)
                    .foregroundColor(VYRISColors.Vault.textOnDarkSecondary)

                Spacer()

                Button {
                    authenticateWithBiometrics()
                } label: {
                    VStack(spacing: VYRISSpacing.sm) {
                        Image(systemName: "faceid")
                            .font(.system(size: 32, weight: .ultraLight))
                            .foregroundColor(VYRISColors.Vault.champagne)

                        Text("vault.unlock")
                            .font(VYRISTypography.meta())
                            .foregroundColor(VYRISColors.Vault.textOnDarkSecondary)
                            .tracking(1.5)
                            .textCase(.uppercase)
                    }
                }
                .buttonStyle(.plain)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            authenticateWithBiometrics()
        }
    }

    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Biometrics unavailable — unlock directly
            withAnimation(.easeOut(duration: 0.4)) { isVaultUnlocked = true }
            return
        }

        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: NSLocalizedString("vault.biometricReason", comment: "")
        ) { success, _ in
            DispatchQueue.main.async {
                if success {
                    VYRISHaptics.rigid()
                    withAnimation(.easeOut(duration: 0.4)) { isVaultUnlocked = true }
                }
            }
        }
    }

    // MARK: - Vault Content (Unlocked)

    private func vaultContent(repository: CardRepository) -> some View {
        GeometryReader { geometry in
            ZStack {
                VaultBackground()

                VStack(spacing: 0) {
                    // Minimal header — just VYRIS mark
                    vaultHeader
                        .opacity(isCardRevealed ? 0.4 : 1.0)

                    Spacer()

                    if let card = repository.activeCard {
                        // The card in its sleeve
                        cardInSleeve(card: card, geometry: geometry)
                    } else {
                        emptyVault(repository: repository)
                    }
                }

                // Card selector at bottom (only when multiple cards and card is revealed)
                if repository.cards.count > 1 && isCardRevealed {
                    VStack {
                        Spacer()
                        cardSelector(repository: repository)
                            .padding(.bottom, VYRISSpacing.lg)
                    }
                }
            }
            // Two-finger long-press for action sheet
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .simultaneously(with: LongPressGesture(minimumDuration: 0.5))
                    .onEnded { _ in
                        VYRISHaptics.medium()
                        showActionSheet = true
                    }
            )
        }
        .confirmationDialog("", isPresented: $showActionSheet, titleVisibility: .hidden) {
            if repository.activeCard != nil {
                Button { editingCard = repository.activeCard; showEditor = true } label: {
                    Text("vault.action.edit")
                }
                Button { showPresent = true } label: {
                    Text("vault.action.present")
                }
            }
            Button { showCommission = true } label: {
                Text("vault.action.commission")
            }
            Button { showSettings = true } label: {
                Text("vault.action.settings")
            }
        }
        .sheet(isPresented: $showEditor) {
            CardEditorView(repository: repository, card: editingCard)
                .environment(localization)
        }
        .sheet(isPresented: $showCommission) {
            CommissionFlowView(repository: repository)
                .environment(localization)
                .environment(motionManager)
        }
        .fullScreenCover(isPresented: $showPresent) {
            if let card = repository.activeCard {
                PresentModeView(card: card, settings: settings)
                    .environment(motionManager)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(settings: settings, localization: localization)
        }
        .sheet(isPresented: $showScanner) {
            QRScannerView()
        }
    }

    // MARK: - Vault Header

    private var vaultHeader: some View {
        HStack {
            VYRISBrandMark(size: 12)
                .foregroundColor(VYRISColors.Vault.textOnDarkSecondary)
            Spacer()
            if repository?.cards.isEmpty == false {
                Button { showScanner = true } label: {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(VYRISColors.Vault.textOnDarkSecondary)
                }
            }
        }
        .padding(.horizontal, VYRISSpacing.lg)
        .padding(.top, VYRISSpacing.sm)
        .animation(.easeOut(duration: 0.3), value: isCardRevealed)
    }

    // MARK: - Card in Sleeve

    private func cardInSleeve(card: BusinessCard, geometry: GeometryProxy) -> some View {
        let cardHeight = (geometry.size.width - VYRISCardDimensions.horizontalInset * 2)
            / VYRISCardDimensions.aspectRatio
        let visibleAmount = cardHeight * sleeveVisibleFraction
        let totalSleeveTravel = cardHeight - visibleAmount
        let currentOffset = isCardRevealed ? 0 : totalSleeveTravel

        return ZStack(alignment: .bottom) {
            // The card
            VStack(spacing: 0) {
                Spacer()

                cardDisplay(card: card)
                    .padding(.horizontal, VYRISCardDimensions.horizontalInset)
                    .offset(y: currentOffset + dragOffset)

                Spacer().frame(height: VYRISSpacing.xxl)
            }

            // Sleeve overlay — covers bottom of card when tucked
            if !isCardRevealed {
                sleeveOverlay(geometry: geometry)
                    .offset(y: dragOffset * 0.3) // Sleeve moves slower than card
            }
        }
        .gesture(
            DragGesture(minimumDistance: 10)
                .onChanged { value in
                    if !isCardRevealed {
                        // Only allow upward drag to reveal
                        let translation = min(0, value.translation.height)
                        dragOffset = translation * 0.6 // Friction
                    } else {
                        // Allow downward drag to tuck
                        let translation = max(0, value.translation.height)
                        dragOffset = translation * 0.6
                    }
                }
                .onEnded { value in
                    let velocity = value.predictedEndTranslation.height - value.translation.height
                    if !isCardRevealed {
                        if -value.translation.height > revealThreshold || velocity < -200 {
                            revealCard()
                        } else {
                            cancelReveal()
                        }
                    } else {
                        if value.translation.height > revealThreshold || velocity > 200 {
                            tuckCard()
                        } else {
                            cancelTuck()
                        }
                    }
                }
        )
    }

    // MARK: - Card Display (Front/Back with Flip)

    private func cardDisplay(card: BusinessCard) -> some View {
        let theme = card.resolvedTheme()
        return ZStack {
            // Front
            CardFrontView(
                card: card,
                theme: theme,
                tiltX: isFlipped ? 0 : motionManager.pitch,
                tiltY: isFlipped ? 0 : motionManager.roll,
                motionEnabled: settings.motionEnabled && !isFlipped
            )
            .opacity(flipDegrees.truncatingRemainder(dividingBy: 360) < 90
                     || flipDegrees.truncatingRemainder(dividingBy: 360) > 270 ? 1 : 0)

            // Back
            CardBackView(card: card, theme: theme)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(flipDegrees.truncatingRemainder(dividingBy: 360) >= 90
                         && flipDegrees.truncatingRemainder(dividingBy: 360) <= 270 ? 1 : 0)
        }
        .rotation3DEffect(.degrees(flipDegrees), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
        .if(settings.motionEnabled && !isFlipped) { view in
            view
                .rotation3DEffect(.degrees(motionManager.backgroundPitch), axis: (x: 1, y: 0, z: 0))
                .rotation3DEffect(.degrees(motionManager.backgroundRoll), axis: (x: 0, y: 1, z: 0))
        }
        .vyrisShadow(isFlipped ? VYRISShadow.subtle : VYRISShadow.cardResting)
        .onTapGesture {
            if isCardRevealed {
                performFlip()
            }
        }
    }

    private func performFlip() {
        VYRISHaptics.rigid()
        withAnimation(.easeInOut(duration: 0.7)) { flipDegrees += 180 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { isFlipped.toggle() }
    }

    // MARK: - Sleeve Overlay

    private func sleeveOverlay(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack(alignment: .top) {
                // Sleeve gradient — fades into vault darkness
                LinearGradient(
                    colors: [
                        VYRISColors.Vault.sleeveGradientTop,
                        VYRISColors.Vault.sleeveGradientBottom
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: geometry.size.height * 0.5)

                // Subtle sleeve edge line
                Rectangle()
                    .fill(VYRISColors.Vault.champagne.opacity(0.15))
                    .frame(height: 0.5)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .allowsHitTesting(false)
    }

    // MARK: - Reveal/Tuck Animations

    private func revealCard() {
        VYRISHaptics.rigid()
        withAnimation(.easeOut(duration: 0.5)) {
            isCardRevealed = true
            dragOffset = 0
        }
    }

    private func cancelReveal() {
        withAnimation(.easeOut(duration: 0.3)) {
            dragOffset = 0
        }
    }

    private func tuckCard() {
        VYRISHaptics.soft()
        // Reset flip state when tucking
        if isFlipped {
            withAnimation(.easeInOut(duration: 0.5)) { flipDegrees += 180 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { isFlipped = false }
        }
        withAnimation(.easeOut(duration: 0.5)) {
            isCardRevealed = false
            dragOffset = 0
        }
    }

    private func cancelTuck() {
        withAnimation(.easeOut(duration: 0.3)) {
            dragOffset = 0
        }
    }

    // MARK: - Empty Vault

    private func emptyVault(repository: CardRepository) -> some View {
        VStack(spacing: VYRISSpacing.lg) {
            Spacer()

            Text("vault.empty")
                .font(VYRISTypography.body())
                .foregroundColor(VYRISColors.Vault.textOnDarkSecondary)

            Button {
                showCommission = true
            } label: {
                Text("vault.commission")
                    .font(VYRISTypography.button())
                    .foregroundColor(VYRISColors.Vault.champagne)
                    .tracking(1.5)
                    .textCase(.uppercase)
            }
            .buttonStyle(.plain)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Card Selector

    private func cardSelector(repository: CardRepository) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: VYRISSpacing.xs) {
                    ForEach(repository.cards) { card in
                        let theme = card.resolvedTheme()
                        let isActive = repository.activeCard?.id == card.id

                        RoundedRectangle(cornerRadius: 3)
                            .fill(theme.backgroundColor)
                            .frame(width: 44, height: 28)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .strokeBorder(
                                        isActive ? VYRISColors.Vault.champagne : theme.strokeColor.opacity(0.3),
                                        lineWidth: isActive ? 1.0 : 0.5
                                    )
                            )
                            .scaleEffect(isActive ? 1.1 : 1.0)
                            .id(card.id)
                            .onTapGesture {
                                VYRISHaptics.selection()
                                withAnimation(.easeOut(duration: 0.3)) {
                                    repository.setActiveCard(id: card.id)
                                    // Reset flip when switching cards
                                    if isFlipped {
                                        flipDegrees += 180
                                        isFlipped = false
                                    }
                                }
                            }
                    }
                }
                .padding(.horizontal, VYRISSpacing.lg)
            }
            .onChange(of: repository.activeCardId) { _, _ in
                if let activeId = repository.activeCard?.id {
                    withAnimation { proxy.scrollTo(activeId, anchor: .center) }
                }
            }
        }
    }
}

// MARK: - Vault Background
// Obsidian-deep background with ultra-subtle grain.

struct VaultBackground: View {
    var body: some View {
        ZStack {
            VYRISColors.Vault.obsidianDeep
                .ignoresSafeArea()

            MaterialGrainLayer()
                .opacity(0.02)
                .ignoresSafeArea()
        }
    }
}

// MARK: - Present Mode View
// Zero chrome. Card + QR flip only. Tap to dismiss.

struct PresentModeView: View {
    let card: BusinessCard
    let settings: AppSettings
    @Environment(MotionManager.self) private var motionManager
    @Environment(\.dismiss) private var dismiss

    @State private var isFlipped = false
    @State private var flipDegrees: Double = 0

    private var theme: CardTheme { card.resolvedTheme() }

    var body: some View {
        ZStack {
            VYRISColors.Vault.obsidianDeep.ignoresSafeArea()

            VStack {
                Spacer()

                ZStack {
                    CardFrontView(
                        card: card,
                        theme: theme,
                        tiltX: isFlipped ? 0 : motionManager.pitch,
                        tiltY: isFlipped ? 0 : motionManager.roll,
                        motionEnabled: settings.motionEnabled && !isFlipped
                    )
                    .opacity(flipDegrees.truncatingRemainder(dividingBy: 360) < 90
                             || flipDegrees.truncatingRemainder(dividingBy: 360) > 270 ? 1 : 0)

                    CardBackView(card: card, theme: theme)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .opacity(flipDegrees.truncatingRemainder(dividingBy: 360) >= 90
                                 && flipDegrees.truncatingRemainder(dividingBy: 360) <= 270 ? 1 : 0)
                }
                .rotation3DEffect(.degrees(flipDegrees), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
                .if(settings.motionEnabled && !isFlipped) { view in
                    view
                        .rotation3DEffect(.degrees(motionManager.backgroundPitch), axis: (x: 1, y: 0, z: 0))
                        .rotation3DEffect(.degrees(motionManager.backgroundRoll), axis: (x: 0, y: 1, z: 0))
                }
                .vyrisShadow(VYRISShadow.cardResting)
                .padding(.horizontal, VYRISCardDimensions.horizontalInset)
                .onTapGesture {
                    VYRISHaptics.rigid()
                    withAnimation(.easeInOut(duration: 0.7)) { flipDegrees += 180 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { isFlipped.toggle() }
                }

                Spacer()
            }

            // Dismiss zone: swipe down or tap edges
            VStack {
                HStack {
                    Spacer()
                    // Invisible dismiss target
                    Color.clear
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                        .onTapGesture { dismiss() }
                }
                Spacer()
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.height > 100 {
                        dismiss()
                    }
                }
        )
        .statusBarHidden()
    }
}
