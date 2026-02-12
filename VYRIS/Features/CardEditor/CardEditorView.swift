import SwiftUI

// MARK: - Card Editor
// Full card editing with theme selection, social links, photo support.

struct CardEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var repository: CardRepository

    @State private var fullName: String
    @State private var title: String
    @State private var company: String
    @State private var phone: String
    @State private var email: String
    @State private var website: String
    @State private var socialLinks: [SocialLink]
    @State private var themeId: String
    @State private var showDeleteConfirm = false
    @State private var showThemePicker = false

    private let existingCard: BusinessCard?
    private var isEditing: Bool { existingCard != nil }

    init(repository: CardRepository, card: BusinessCard? = nil) {
        self.repository = repository
        self.existingCard = card

        _fullName = State(initialValue: card?.fullName ?? "")
        _title = State(initialValue: card?.title ?? "")
        _company = State(initialValue: card?.company ?? "")
        _phone = State(initialValue: card?.phone ?? "")
        _email = State(initialValue: card?.email ?? "")
        _website = State(initialValue: card?.website ?? "")
        _socialLinks = State(initialValue: card?.socialLinks ?? [])
        _themeId = State(initialValue: card?.themeId ?? "ivory_classic")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VYRISColors.Semantic.backgroundPrimary
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: VYRISSpacing.lg) {
                        // Live preview
                        cardPreview
                            .padding(.top, VYRISSpacing.sm)

                        VYRISDivider()
                            .padding(.horizontal, VYRISSpacing.lg)

                        // Form fields
                        formFields

                        // Theme picker
                        themeSection

                        // Social links
                        socialLinksSection

                        // Delete button (edit mode only)
                        if isEditing {
                            deleteSection
                        }

                        Spacer(minLength: VYRISSpacing.xxl)
                    }
                }
            }
            .navigationTitle(Text("editor.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("editor.cancel")
                            .font(VYRISTypography.body())
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        save()
                    } label: {
                        Text("editor.save")
                            .font(VYRISTypography.button())
                            .foregroundColor(VYRISColors.Semantic.accent)
                    }
                    .disabled(fullName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("editor.deleteConfirm", isPresented: $showDeleteConfirm) {
                Button("common.delete", role: .destructive) {
                    if let card = existingCard {
                        repository.deleteCard(card)
                    }
                    dismiss()
                }
                Button("common.cancel", role: .cancel) {}
            }
        }
    }

    // MARK: - Live Preview

    private var cardPreview: some View {
        let previewCard = BusinessCard(
            fullName: fullName.isEmpty ? "Your Name" : fullName,
            title: title,
            company: company,
            phone: phone,
            email: email,
            website: website,
            socialLinks: socialLinks,
            themeId: themeId
        )
        let theme = ThemeRegistry.theme(for: themeId)

        return CardFrontView(
            card: previewCard,
            theme: theme,
            tiltX: 0,
            tiltY: 0,
            motionEnabled: false
        )
        .padding(.horizontal, VYRISSpacing.xl)
        .vyrisShadow(VYRISShadow.cardResting)
    }

    // MARK: - Form Fields

    private var formFields: some View {
        VStack(spacing: VYRISSpacing.md) {
            EditorField(label: "editor.fullName", text: $fullName)
            EditorField(label: "editor.jobTitle", text: $title)
            EditorField(label: "editor.company", text: $company)
            EditorField(label: "editor.phone", text: $phone, keyboardType: .phonePad)
            EditorField(label: "editor.email", text: $email, keyboardType: .emailAddress)
            EditorField(label: "editor.website", text: $website, keyboardType: .URL)
        }
        .padding(.horizontal, VYRISSpacing.lg)
    }

    // MARK: - Theme Section

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: VYRISSpacing.sm) {
            Text("editor.theme")
                .font(VYRISTypography.meta())
                .foregroundColor(VYRISColors.Semantic.textSecondary)
                .tracking(1)
                .textCase(.uppercase)
                .padding(.horizontal, VYRISSpacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: VYRISSpacing.sm) {
                    ForEach(ThemeRegistry.allThemes) { theme in
                        themeChip(theme: theme)
                    }
                }
                .padding(.horizontal, VYRISSpacing.lg)
            }
        }
    }

    private func themeChip(theme: CardTheme) -> some View {
        let isSelected = theme.id == themeId

        return VStack(spacing: VYRISSpacing.xxs) {
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.backgroundColor)
                .frame(width: 56, height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            isSelected ? VYRISColors.Semantic.accent : theme.strokeColor,
                            lineWidth: isSelected ? 2 : 0.5
                        )
                )

            Text(theme.name)
                .font(VYRISTypography.caption())
                .foregroundColor(
                    isSelected
                    ? VYRISColors.Semantic.textPrimary
                    : VYRISColors.Semantic.textSecondary
                )
                .lineLimit(1)
        }
        .frame(width: 64)
        .onTapGesture {
            VYRISHaptics.selection()
            withAnimation(.easeInOut(duration: 0.2)) {
                themeId = theme.id
            }
        }
    }

    // MARK: - Social Links

    private var socialLinksSection: some View {
        VStack(alignment: .leading, spacing: VYRISSpacing.sm) {
            HStack {
                Text("editor.socialLinks")
                    .font(VYRISTypography.meta())
                    .foregroundColor(VYRISColors.Semantic.textSecondary)
                    .tracking(1)
                    .textCase(.uppercase)

                Spacer()

                Button {
                    socialLinks.append(SocialLink(platform: "LinkedIn", url: ""))
                } label: {
                    Text("editor.addLink")
                        .font(VYRISTypography.meta())
                        .foregroundColor(VYRISColors.Semantic.accent)
                }
            }
            .padding(.horizontal, VYRISSpacing.lg)

            ForEach($socialLinks) { $link in
                HStack(spacing: VYRISSpacing.sm) {
                    Menu {
                        ForEach(SocialLink.platforms, id: \.self) { platform in
                            Button(platform) {
                                link.platform = platform
                            }
                        }
                    } label: {
                        Text(link.platform)
                            .font(VYRISTypography.meta())
                            .foregroundColor(VYRISColors.Semantic.accent)
                            .frame(width: 80, alignment: .leading)
                    }

                    TextField("URL", text: $link.url)
                        .font(VYRISTypography.body())
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    Button {
                        socialLinks.removeAll { $0.id == link.id }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12))
                            .foregroundColor(VYRISColors.Semantic.textSecondary)
                    }
                }
                .padding(.horizontal, VYRISSpacing.lg)
            }
        }
    }

    // MARK: - Delete

    private var deleteSection: some View {
        Button {
            showDeleteConfirm = true
        } label: {
            Text("editor.delete")
                .font(VYRISTypography.button())
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, VYRISSpacing.md)
        }
        .padding(.horizontal, VYRISSpacing.lg)
        .padding(.top, VYRISSpacing.lg)
    }

    // MARK: - Save

    private func save() {
        if let card = existingCard {
            card.fullName = fullName
            card.title = title
            card.company = company
            card.phone = phone
            card.email = email
            card.website = website
            card.socialLinks = socialLinks
            card.themeId = themeId
            repository.updateCard(card)
        } else {
            let newCard = BusinessCard(
                fullName: fullName,
                title: title,
                company: company,
                phone: phone,
                email: email,
                website: website,
                socialLinks: socialLinks,
                themeId: themeId
            )
            repository.addCard(newCard)
        }
        dismiss()
    }
}

// MARK: - Editor Field Component

struct EditorField: View {
    let label: LocalizedStringKey
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
            Text(label)
                .font(VYRISTypography.meta())
                .foregroundColor(VYRISColors.Semantic.textSecondary)
                .tracking(0.5)

            TextField("", text: $text)
                .font(VYRISTypography.body())
                .foregroundColor(VYRISColors.Semantic.textPrimary)
                .keyboardType(keyboardType)
                .autocorrectionDisabled()
                .textInputAutocapitalization(keyboardType == .default ? .words : .never)
                .padding(.vertical, VYRISSpacing.xs)
                .overlay(
                    VYRISDivider(),
                    alignment: .bottom
                )
        }
    }
}
