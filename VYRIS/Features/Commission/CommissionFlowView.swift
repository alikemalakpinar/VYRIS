import SwiftUI

// MARK: - Commission Flow View
// "Commission Your Identity" — luxury ritual for creating a new card.
// Steps: Choose Material → Engrave Name → Add Essentials → Select Tier → Preview → Issue
// The card itself is the hero — no generic illustrations.

struct CommissionFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var localization
    @Environment(MotionManager.self) private var motionManager
    @Bindable var repository: CardRepository

    @State private var currentStep: CommissionStep = .material
    @State private var selectedMaterial: MaterialVariant = .obsidian
    @State private var selectedTier: CardTier = .standard
    @State private var fullName = ""
    @State private var jobTitle = ""
    @State private var company = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var themeId = "midnight_gold"
    @State private var isIssued = false
    @State private var issueAnimating = false

    enum CommissionStep: Int, CaseIterable {
        case material = 0
        case engrave = 1
        case essentials = 2
        case tier = 3
        case preview = 4

        var progressFraction: CGFloat {
            CGFloat(rawValue + 1) / CGFloat(CommissionStep.allCases.count)
        }
    }

    // Theme mapped to material for preview
    private var previewThemeId: String {
        switch selectedMaterial {
        case .obsidian: return "midnight_gold"
        case .titanium: return "navy_executive"
        case .ivory: return "ivory_classic"
        }
    }

    private var previewCard: BusinessCard {
        BusinessCard(
            fullName: fullName.isEmpty ? " " : fullName,
            title: jobTitle,
            company: company,
            phone: phone,
            email: email,
            themeId: previewThemeId,
            materialVariant: selectedMaterial,
            tier: selectedTier
        )
    }

    var body: some View {
        ZStack {
            VaultBackground()

            VStack(spacing: 0) {
                // Progress bar
                progressBar
                    .padding(.top, VYRISSpacing.sm)

                if isIssued {
                    issuedConfirmation
                } else {
                    // Step content
                    stepContent
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }

            // Navigation buttons
            if !isIssued {
                VStack {
                    // Close button
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(VYRISColors.Vault.textOnDarkSecondary)
                                .frame(width: 32, height: 32)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, VYRISSpacing.lg)
                    .padding(.top, VYRISSpacing.xs)

                    Spacer()

                    // Next / Issue
                    bottomAction
                        .padding(.bottom, VYRISSpacing.xxl)
                }
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(VYRISColors.Vault.obsidianElevated)
                    .frame(height: 2)

                Rectangle()
                    .fill(VYRISColors.Vault.champagne)
                    .frame(width: geometry.size.width * currentStep.progressFraction, height: 2)
                    .animation(.easeOut(duration: 0.4), value: currentStep)
            }
        }
        .frame(height: 2)
        .padding(.horizontal, VYRISSpacing.lg)
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .material:
            materialStep
        case .engrave:
            engraveStep
        case .essentials:
            essentialsStep
        case .tier:
            tierStep
        case .preview:
            previewStep
        }
    }

    // MARK: - Step 1: Choose Material

    private var materialStep: some View {
        VStack(spacing: VYRISSpacing.xl) {
            Spacer()

            Text("commission.chooseMaterial")
                .font(VYRISTypography.meta())
                .foregroundColor(VYRISColors.Vault.textOnDarkSecondary)
                .tracking(2)
                .textCase(.uppercase)

            // Full-screen card render
            MaterialSurfaceView(
                material: selectedMaterial,
                tier: .executive,
                tiltX: motionManager.pitch,
                tiltY: motionManager.roll,
                cornerRadius: VYRISCardDimensions.cornerRadius
            )
            .aspectRatio(VYRISCardDimensions.aspectRatio, contentMode: .fit)
            .padding(.horizontal, VYRISCardDimensions.horizontalInset)
            .vyrisShadow(VYRISShadow.cardResting)

            // Material selector
            HStack(spacing: VYRISSpacing.xl) {
                ForEach(MaterialVariant.allCases) { material in
                    materialChip(material)
                }
            }

            Spacer()
            Spacer()
        }
    }

    private func materialChip(_ material: MaterialVariant) -> some View {
        let isSelected = selectedMaterial == material
        return VStack(spacing: VYRISSpacing.xxs) {
            RoundedRectangle(cornerRadius: 3)
                .fill(material.baseColor)
                .frame(width: 48, height: 32)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .strokeBorder(
                            isSelected ? VYRISColors.Vault.champagne : Color.clear,
                            lineWidth: 1
                        )
                )

            Text(material.localizationKey)
                .font(.system(size: 10, weight: isSelected ? .medium : .regular))
                .foregroundColor(isSelected ? VYRISColors.Vault.champagne : VYRISColors.Vault.textOnDarkSecondary)
                .tracking(1)
        }
        .onTapGesture {
            VYRISHaptics.selection()
            withAnimation(.easeOut(duration: 0.3)) {
                selectedMaterial = material
            }
        }
    }

    // MARK: - Step 2: Engrave Name

    private var engraveStep: some View {
        VStack(spacing: VYRISSpacing.xl) {
            Spacer()

            Text("commission.engraveName")
                .font(VYRISTypography.meta())
                .foregroundColor(VYRISColors.Vault.textOnDarkSecondary)
                .tracking(2)
                .textCase(.uppercase)

            // Live card preview with name
            previewCardView
                .padding(.horizontal, VYRISCardDimensions.horizontalInset)

            // Name field — styled as "engraving line"
            VStack(spacing: VYRISSpacing.xxs) {
                TextField("", text: $fullName, prompt: Text("commission.namePlaceholder")
                    .foregroundColor(VYRISColors.Vault.textOnDarkSecondary.opacity(0.3)))
                .font(.system(size: 22, weight: .regular, design: .serif))
                .foregroundColor(VYRISColors.Vault.textOnDark)
                .multilineTextAlignment(.center)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)

                Rectangle()
                    .fill(VYRISColors.Vault.champagne.opacity(0.3))
                    .frame(height: 0.5)
                    .frame(maxWidth: 200)
            }
            .padding(.horizontal, VYRISSpacing.xxl)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Step 3: Add Essentials

    private var essentialsStep: some View {
        ScrollView {
            VStack(spacing: VYRISSpacing.lg) {
                Text("commission.addEssentials")
                    .font(VYRISTypography.meta())
                    .foregroundColor(VYRISColors.Vault.textOnDarkSecondary)
                    .tracking(2)
                    .textCase(.uppercase)
                    .padding(.top, VYRISSpacing.xxl)

                // Mini card preview
                previewCardView
                    .padding(.horizontal, VYRISCardDimensions.horizontalInset)
                    .scaleEffect(0.85)

                // Engraving fields
                VStack(spacing: VYRISSpacing.md) {
                    commissionField("commission.field.title", text: $jobTitle)
                    commissionField("commission.field.company", text: $company)
                    commissionField("commission.field.phone", text: $phone, keyboard: .phonePad)
                    commissionField("commission.field.email", text: $email, keyboard: .emailAddress)
                }
                .padding(.horizontal, VYRISSpacing.xl)

                Spacer(minLength: 120)
            }
        }
    }

    private func commissionField(
        _ label: LocalizedStringKey,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
            Text(label)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(VYRISColors.Vault.textOnDarkSecondary.opacity(0.5))
                .tracking(1.5)
                .textCase(.uppercase)

            TextField("", text: text)
                .font(.system(size: 17, weight: .regular, design: .serif))
                .foregroundColor(VYRISColors.Vault.textOnDark)
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .textInputAutocapitalization(keyboard == .default ? .words : .never)

            Rectangle()
                .fill(VYRISColors.Vault.obsidianElevated)
                .frame(height: 0.5)
        }
    }

    // MARK: - Step 4: Select Tier

    private var tierStep: some View {
        VStack(spacing: VYRISSpacing.xl) {
            Spacer()

            Text("commission.selectTier")
                .font(VYRISTypography.meta())
                .foregroundColor(VYRISColors.Vault.textOnDarkSecondary)
                .tracking(2)
                .textCase(.uppercase)

            // Card preview with live tier effect
            MaterialSurfaceView(
                material: selectedMaterial,
                tier: selectedTier,
                tiltX: motionManager.pitch,
                tiltY: motionManager.roll,
                cornerRadius: VYRISCardDimensions.cornerRadius
            )
            .aspectRatio(VYRISCardDimensions.aspectRatio, contentMode: .fit)
            .overlay(
                VStack {
                    Spacer()
                    Text(fullName)
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .foregroundColor(selectedMaterial.textColor)
                        .padding(.bottom, VYRISSpacing.xl)
                }
            )
            .padding(.horizontal, VYRISCardDimensions.horizontalInset)
            .vyrisShadow(VYRISShadow.cardResting)

            // Tier selection
            HStack(spacing: VYRISSpacing.lg) {
                ForEach(CardTier.allCases) { tier in
                    tierChip(tier)
                }
            }

            Spacer()
            Spacer()
        }
    }

    private func tierChip(_ tier: CardTier) -> some View {
        let isSelected = selectedTier == tier
        return VStack(spacing: VYRISSpacing.xs) {
            VStack(spacing: 2) {
                Text(tier.localizationKey)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? VYRISColors.Vault.champagne : VYRISColors.Vault.textOnDarkSecondary)
                    .tracking(1)

                // Visual indicator of tier features
                HStack(spacing: 3) {
                    Circle()
                        .fill(VYRISColors.Vault.textOnDarkSecondary.opacity(0.3))
                        .frame(width: 4, height: 4)
                    if tier.hasSpecular {
                        Circle()
                            .fill(VYRISColors.Vault.champagne.opacity(0.5))
                            .frame(width: 4, height: 4)
                    }
                    if tier.hasEdgeIllumination {
                        Circle()
                            .fill(VYRISColors.Vault.champagne)
                            .frame(width: 4, height: 4)
                    }
                }
            }
            .padding(.horizontal, VYRISSpacing.md)
            .padding(.vertical, VYRISSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(
                        isSelected ? VYRISColors.Vault.champagne.opacity(0.5) : VYRISColors.Vault.obsidianElevated,
                        lineWidth: 0.5
                    )
            )
        }
        .onTapGesture {
            VYRISHaptics.selection()
            withAnimation(.easeOut(duration: 0.3)) {
                selectedTier = tier
            }
        }
    }

    // MARK: - Step 5: Preview

    private var previewStep: some View {
        VStack(spacing: VYRISSpacing.lg) {
            Spacer()

            Text("commission.preview")
                .font(VYRISTypography.meta())
                .foregroundColor(VYRISColors.Vault.textOnDarkSecondary)
                .tracking(2)
                .textCase(.uppercase)

            // Full card preview in vault context
            previewCardView
                .padding(.horizontal, VYRISCardDimensions.horizontalInset)
                .vyrisShadow(VYRISShadow.cardElevated)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Preview Card View

    private var previewCardView: some View {
        CardFrontView(
            card: previewCard,
            theme: previewCard.resolvedTheme(),
            tiltX: motionManager.pitch,
            tiltY: motionManager.roll,
            motionEnabled: true
        )
    }

    // MARK: - Bottom Action

    private var bottomAction: some View {
        HStack {
            // Back button
            if currentStep.rawValue > 0 {
                Button {
                    VYRISHaptics.light()
                    withAnimation(.easeOut(duration: 0.4)) {
                        if let prev = CommissionStep(rawValue: currentStep.rawValue - 1) {
                            currentStep = prev
                        }
                    }
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(VYRISColors.Vault.textOnDarkSecondary)
                        .frame(width: 44, height: 44)
                }
            }

            Spacer()

            // Next / Issue button
            Button {
                if currentStep == .preview {
                    issueCard()
                } else {
                    advanceStep()
                }
            } label: {
                Text(currentStep == .preview ? "commission.issue" : "commission.next")
                    .font(VYRISTypography.button())
                    .foregroundColor(
                        canAdvance
                            ? VYRISColors.Vault.obsidian
                            : VYRISColors.Vault.textOnDarkSecondary.opacity(0.3)
                    )
                    .tracking(1.5)
                    .textCase(.uppercase)
                    .padding(.horizontal, VYRISSpacing.xl)
                    .padding(.vertical, VYRISSpacing.sm)
                    .background(
                        Capsule()
                            .fill(canAdvance
                                  ? VYRISColors.Vault.champagne
                                  : VYRISColors.Vault.obsidianElevated)
                    )
            }
            .disabled(!canAdvance)
        }
        .padding(.horizontal, VYRISSpacing.lg)
    }

    private var canAdvance: Bool {
        switch currentStep {
        case .material: return true
        case .engrave: return !fullName.trimmingCharacters(in: .whitespaces).isEmpty
        case .essentials: return true
        case .tier: return true
        case .preview: return true
        }
    }

    private func advanceStep() {
        VYRISHaptics.selection()
        withAnimation(.easeOut(duration: 0.4)) {
            if let next = CommissionStep(rawValue: currentStep.rawValue + 1) {
                currentStep = next
            }
        }
    }

    // MARK: - Issue Card

    private func issueCard() {
        VYRISHaptics.issuance()
        issueAnimating = true

        withAnimation(.easeOut(duration: 0.6)) {
            isIssued = true
        }

        // Actually create the card
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let newCard = BusinessCard(
                fullName: fullName,
                title: jobTitle,
                company: company,
                phone: phone,
                email: email,
                themeId: previewThemeId,
                materialVariant: selectedMaterial,
                tier: selectedTier
            )
            repository.addCard(newCard)
        }

        // Dismiss after showing confirmation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            dismiss()
        }
    }

    // MARK: - Issued Confirmation

    private var issuedConfirmation: some View {
        VStack(spacing: VYRISSpacing.xl) {
            Spacer()

            // Card drops into place with heavy easing
            previewCardView
                .padding(.horizontal, VYRISCardDimensions.horizontalInset)
                .scaleEffect(issueAnimating ? 0.9 : 1.0)
                .opacity(issueAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.8), value: issueAnimating)

            Text("commission.issued")
                .font(VYRISTypography.meta())
                .foregroundColor(VYRISColors.Vault.champagne)
                .tracking(2)
                .textCase(.uppercase)
                .opacity(issueAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.3), value: issueAnimating)

            Spacer()
            Spacer()
        }
    }
}
