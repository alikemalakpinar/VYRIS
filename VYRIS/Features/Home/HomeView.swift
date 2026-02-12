import SwiftUI

// MARK: - Home Screen (Layout C)
// Minimal header, center active card, horizontal snap-based card selector,
// text-only action buttons. Uses resolvedTheme() for custom theme support.

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var repository: CardRepository?
    @State private var motionManager = MotionManager()
    @State private var showEditor = false
    @State private var showPresent = false
    @State private var editingCard: BusinessCard?

    let settings: AppSettings
    let localization: LocalizationManager

    var body: some View {
        Group {
            if let repository {
                homeContent(repository: repository)
            } else {
                Color.clear.onAppear {
                    let repo = CardRepository(modelContext: modelContext)
                    repo.seedIfEmpty()
                    self.repository = repo
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

    @ViewBuilder
    private func homeContent(repository: CardRepository) -> some View {
        ZStack {
            VYRISBackground()

            VStack(spacing: 0) {
                header

                Spacer()

                if let card = repository.activeCard {
                    CardDisplayContainer(
                        card: card,
                        motionManager: motionManager,
                        motionEnabled: settings.motionEnabled
                    )
                    .padding(.horizontal, VYRISCardDimensions.horizontalInset)
                } else {
                    emptyState
                }

                Spacer()

                if repository.activeCard != nil {
                    actionButtons(repository: repository)
                        .padding(.bottom, VYRISSpacing.md)
                }

                if repository.cards.count > 1 {
                    cardSelector(repository: repository)
                        .padding(.bottom, VYRISSpacing.lg)
                } else {
                    Spacer().frame(height: VYRISSpacing.xl)
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            CardEditorView(repository: repository, card: editingCard)
                .environment(localization)
        }
        .fullScreenCover(isPresented: $showPresent) {
            if let card = repository.activeCard {
                PresentView(card: card, settings: settings)
            }
        }
    }

    private var header: some View {
        HStack {
            VYRISBrandMark(size: 16)
            Spacer()
        }
        .padding(.horizontal, VYRISSpacing.lg)
        .padding(.top, VYRISSpacing.sm)
    }

    private var emptyState: some View {
        VStack(spacing: VYRISSpacing.md) {
            Text("home.noCards")
                .font(VYRISTypography.title())
                .foregroundColor(VYRISColors.Semantic.textSecondary)
            Button {
                editingCard = nil; showEditor = true
            } label: {
                Text("home.createFirst")
                    .font(VYRISTypography.button())
                    .foregroundColor(VYRISColors.Semantic.accent)
                    .tracking(1)
            }
        }
    }

    private func actionButtons(repository: CardRepository) -> some View {
        HStack(spacing: VYRISSpacing.xl) {
            VYRISActionButton(title: "home.craft") {
                editingCard = nil; showEditor = true
            }
            VYRISActionButton(title: "home.present") {
                showPresent = true
            }
            VYRISActionButton(title: "home.edit") {
                editingCard = repository.activeCard; showEditor = true
            }
        }
    }

    private func cardSelector(repository: CardRepository) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: VYRISSpacing.sm) {
                    ForEach(Array(repository.cards.enumerated()), id: \.element.id) { index, card in
                        let theme = card.resolvedTheme()
                        cardThumbnail(theme: theme, isActive: index == repository.activeCardIndex)
                            .id(card.id)
                            .onTapGesture {
                                VYRISHaptics.selection()
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    repository.setActiveCard(at: index)
                                }
                            }
                    }
                }
                .padding(.horizontal, VYRISSpacing.lg)
            }
            .onChange(of: repository.activeCardIndex) { _, newIndex in
                guard newIndex < repository.cards.count else { return }
                withAnimation { proxy.scrollTo(repository.cards[newIndex].id, anchor: .center) }
            }
        }
    }

    private func cardThumbnail(theme: CardTheme, isActive: Bool) -> some View {
        ZStack {
            CardBackgroundRenderer(theme: theme)
            if theme.decorationStyle != .none {
                CardDecorationView(
                    style: theme.decorationStyle,
                    accentColor: theme.accentColor,
                    secondaryColor: theme.secondaryTextColor
                )
            }
        }
        .frame(width: VYRISCardDimensions.thumbnailWidth,
               height: VYRISCardDimensions.thumbnailHeight)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(
                    isActive ? VYRISColors.Semantic.accent : theme.strokeColor,
                    lineWidth: isActive ? 1.5 : 0.5
                )
        )
        .scaleEffect(isActive ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

// MARK: - Present View

struct PresentView: View {
    let card: BusinessCard
    let settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    private var theme: CardTheme { card.resolvedTheme() }

    var body: some View {
        ZStack {
            VYRISColors.Semantic.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: VYRISSpacing.xl) {
                Spacer()

                Text(card.fullName)
                    .font(VYRISTypography.cardName(size: 24))
                    .foregroundColor(VYRISColors.Semantic.textPrimary)

                QRCodeView(
                    card: card, size: 240,
                    tintColor: VYRISColors.Semantic.textPrimary
                )

                Text("qr.scanToAdd")
                    .font(VYRISTypography.meta())
                    .foregroundColor(VYRISColors.Semantic.textSecondary)

                Spacer()

                Button { dismiss() } label: {
                    Text("common.done")
                        .font(VYRISTypography.button())
                        .foregroundColor(VYRISColors.Semantic.accent)
                        .tracking(1.5).textCase(.uppercase)
                }
                .padding(.bottom, VYRISSpacing.xl)
            }
        }
        .onTapGesture { dismiss() }
    }
}
