import SwiftUI
import PhotosUI

// MARK: - Card Editor
// Full card editing: fields, photo/logo pickers, theme presets,
// full custom theme access, social links.

struct CardEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var repository: CardRepository

    @State private var fullName: String
    @State private var title: String
    @State private var company: String
    @State private var phone: String
    @State private var email: String
    @State private var website: String
    @State private var bio: String
    @State private var location: String
    @State private var socialLinks: [SocialLink]
    @State private var themeId: String
    @State private var isCustomTheme: Bool
    @State private var customTheme: CustomThemeData
    @State private var photoData: Data?
    @State private var logoData: Data?

    @State private var showDeleteConfirm = false
    @State private var showCustomizer = false
    @State private var photoItem: PhotosPickerItem?
    @State private var logoItem: PhotosPickerItem?

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
        _bio = State(initialValue: card?.bio ?? "")
        _location = State(initialValue: card?.location ?? "")
        _socialLinks = State(initialValue: card?.socialLinks ?? [])
        _themeId = State(initialValue: card?.themeId ?? "ivory_classic")
        _isCustomTheme = State(initialValue: card?.isCustomTheme ?? false)
        _customTheme = State(initialValue: card?.customTheme ?? .default)
        _photoData = State(initialValue: card?.photoData)
        _logoData = State(initialValue: card?.logoData)
    }

    private var previewCard: BusinessCard {
        BusinessCard(
            fullName: fullName.isEmpty ? "Your Name" : fullName,
            title: title,
            company: company,
            phone: phone,
            email: email,
            website: website,
            bio: bio,
            location: location,
            socialLinks: socialLinks,
            themeId: themeId,
            customTheme: isCustomTheme ? customTheme : nil,
            photoData: photoData,
            logoData: logoData,
            isCustomTheme: isCustomTheme
        )
    }

    private var previewTheme: CardTheme {
        previewCard.resolvedTheme()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VYRISColors.Semantic.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: VYRISSpacing.lg) {
                        CardFrontView(
                            card: previewCard,
                            theme: previewTheme,
                            tiltX: 0, tiltY: 0,
                            motionEnabled: false
                        )
                        .padding(.horizontal, VYRISSpacing.xl)
                        .padding(.top, VYRISSpacing.sm)
                        .vyrisShadow(VYRISShadow.cardResting)

                        VYRISDivider().padding(.horizontal, VYRISSpacing.lg)

                        photoSection
                        formFields
                        themeSection
                        customizerButton
                        socialLinksSection

                        if isEditing { deleteSection }

                        Spacer(minLength: VYRISSpacing.xxl)
                    }
                }
            }
            .navigationTitle(Text("editor.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Text("editor.cancel").font(VYRISTypography.body())
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button { save() } label: {
                        Text("editor.save")
                            .font(VYRISTypography.button())
                            .foregroundColor(VYRISColors.Semantic.accent)
                    }
                    .disabled(fullName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("editor.deleteConfirm", isPresented: $showDeleteConfirm) {
                Button("common.delete", role: .destructive) {
                    if let card = existingCard { repository.deleteCard(card) }
                    dismiss()
                }
                Button("common.cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showCustomizer) {
                ThemeCustomizerView(
                    customTheme: $customTheme,
                    isCustom: $isCustomTheme,
                    presetThemeId: $themeId,
                    card: previewCard
                )
            }
            .onChange(of: photoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        photoData = data
                    }
                }
            }
            .onChange(of: logoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        logoData = data
                    }
                }
            }
        }
    }

    // MARK: - Photo & Logo

    private var photoSection: some View {
        HStack(spacing: VYRISSpacing.lg) {
            VStack(spacing: VYRISSpacing.xxs) {
                PhotosPicker(selection: $photoItem, matching: .images) {
                    if let data = photoData, let img = UIImage(data: data) {
                        Image(uiImage: img).resizable().scaledToFill()
                            .frame(width: 64, height: 64).clipShape(Circle())
                    } else {
                        Circle().fill(VYRISColors.Semantic.backgroundSecondary)
                            .frame(width: 64, height: 64)
                            .overlay(Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 20))
                                .foregroundColor(VYRISColors.Semantic.textSecondary))
                    }
                }
                Text("editor.photo").font(VYRISTypography.caption())
                    .foregroundColor(VYRISColors.Semantic.textSecondary)
                if photoData != nil {
                    Button { photoData = nil; photoItem = nil } label: {
                        Text("common.delete").font(.system(size: 10)).foregroundColor(.red)
                    }
                }
            }

            VStack(spacing: VYRISSpacing.xxs) {
                PhotosPicker(selection: $logoItem, matching: .images) {
                    if let data = logoData, let img = UIImage(data: data) {
                        Image(uiImage: img).resizable().scaledToFit()
                            .frame(width: 64, height: 48).clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8).fill(VYRISColors.Semantic.backgroundSecondary)
                            .frame(width: 64, height: 48)
                            .overlay(Image(systemName: "building.2.crop.circle.badge.plus")
                                .font(.system(size: 18))
                                .foregroundColor(VYRISColors.Semantic.textSecondary))
                    }
                }
                Text("editor.logo").font(VYRISTypography.caption())
                    .foregroundColor(VYRISColors.Semantic.textSecondary)
                if logoData != nil {
                    Button { logoData = nil; logoItem = nil } label: {
                        Text("common.delete").font(.system(size: 10)).foregroundColor(.red)
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, VYRISSpacing.lg)
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
            EditorField(label: "editor.bio", text: $bio)
            EditorField(label: "editor.location", text: $location)
        }
        .padding(.horizontal, VYRISSpacing.lg)
    }

    // MARK: - Theme Presets

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: VYRISSpacing.sm) {
            Text("editor.theme")
                .font(VYRISTypography.meta())
                .foregroundColor(VYRISColors.Semantic.textSecondary)
                .tracking(1).textCase(.uppercase)
                .padding(.horizontal, VYRISSpacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: VYRISSpacing.sm) {
                    ForEach(ThemeRegistry.allThemes) { theme in
                        themeChip(theme: theme)
                    }
                }.padding(.horizontal, VYRISSpacing.lg)
            }
        }
    }

    private func themeChip(theme: CardTheme) -> some View {
        let isSelected = !isCustomTheme && theme.id == themeId
        return VStack(spacing: VYRISSpacing.xxs) {
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.backgroundColor)
                .frame(width: 56, height: 36)
                .overlay(
                    VStack(spacing: 1) {
                        Circle().fill(theme.accentColor).frame(width: 4, height: 4)
                        RoundedRectangle(cornerRadius: 0.5)
                            .fill(theme.textColor.opacity(0.5)).frame(width: 20, height: 2)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(isSelected ? VYRISColors.Semantic.accent : theme.strokeColor,
                                      lineWidth: isSelected ? 2 : 0.5)
                )
            Text(theme.displayName).font(VYRISTypography.caption())
                .foregroundColor(isSelected ? VYRISColors.Semantic.textPrimary : VYRISColors.Semantic.textSecondary)
                .lineLimit(1)
        }
        .frame(width: 64)
        .onTapGesture {
            VYRISHaptics.selection()
            withAnimation(.easeInOut(duration: 0.2)) {
                themeId = theme.id; isCustomTheme = false
            }
        }
    }

    // MARK: - Customizer

    private var customizerButton: some View {
        Button {
            if !isCustomTheme {
                let preset = ThemeRegistry.theme(for: themeId)
                customTheme = CustomThemeData(
                    backgroundColorHex: preset.backgroundColor.toHexString(),
                    secondaryBackgroundHex: preset.secondaryBackgroundColor?.toHexString(),
                    textColorHex: preset.textColor.toHexString(),
                    secondaryTextColorHex: preset.secondaryTextColor.toHexString(),
                    accentColorHex: preset.accentColor.toHexString(),
                    strokeColorHex: preset.strokeColor.toHexString(),
                    strokeWidth: Double(preset.strokeWidth),
                    layoutStyle: preset.layoutStyle.rawValue,
                    decorationStyle: preset.decorationStyle.rawValue,
                    fontStyle: preset.fontStyle.rawValue,
                    backgroundStyle: preset.backgroundStyle.rawValue
                )
            }
            showCustomizer = true
        } label: {
            HStack {
                Image(systemName: "paintbrush").font(.system(size: 14))
                Text("customizer.title").font(VYRISTypography.button())
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12))
            }
            .foregroundColor(VYRISColors.Semantic.accent)
            .padding(VYRISSpacing.md)
            .background(RoundedRectangle(cornerRadius: 12).fill(VYRISColors.Semantic.accent.opacity(0.08)))
        }
        .padding(.horizontal, VYRISSpacing.lg)
    }

    // MARK: - Social Links

    private var socialLinksSection: some View {
        VStack(alignment: .leading, spacing: VYRISSpacing.sm) {
            HStack {
                Text("editor.socialLinks").font(VYRISTypography.meta())
                    .foregroundColor(VYRISColors.Semantic.textSecondary)
                    .tracking(1).textCase(.uppercase)
                Spacer()
                Button { socialLinks.append(SocialLink(platform: "LinkedIn", url: "")) } label: {
                    Text("editor.addLink").font(VYRISTypography.meta())
                        .foregroundColor(VYRISColors.Semantic.accent)
                }
            }.padding(.horizontal, VYRISSpacing.lg)

            ForEach($socialLinks) { $link in
                HStack(spacing: VYRISSpacing.sm) {
                    Menu {
                        ForEach(SocialLink.platforms, id: \.self) { p in
                            Button(p) { link.platform = p }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: link.iconName).font(.system(size: 12))
                            Text(link.platform).font(VYRISTypography.meta())
                        }
                        .foregroundColor(VYRISColors.Semantic.accent)
                        .frame(width: 100, alignment: .leading)
                    }

                    TextField("URL", text: $link.url).font(VYRISTypography.body())
                        .keyboardType(.URL).autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    Button { socialLinks.removeAll { $0.id == link.id } } label: {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 16))
                            .foregroundColor(VYRISColors.Semantic.textSecondary.opacity(0.5))
                    }
                }.padding(.horizontal, VYRISSpacing.lg)
            }
        }
    }

    // MARK: - Delete

    private var deleteSection: some View {
        Button { showDeleteConfirm = true } label: {
            Text("editor.delete").font(VYRISTypography.button()).foregroundColor(.red)
                .frame(maxWidth: .infinity).padding(.vertical, VYRISSpacing.md)
        }
        .padding(.horizontal, VYRISSpacing.lg).padding(.top, VYRISSpacing.lg)
    }

    // MARK: - Save

    private func save() {
        if let card = existingCard {
            card.fullName = fullName; card.title = title
            card.company = company; card.phone = phone
            card.email = email; card.website = website
            card.bio = bio; card.location = location
            card.socialLinks = socialLinks; card.themeId = themeId
            card.isCustomTheme = isCustomTheme
            card.customTheme = isCustomTheme ? customTheme : nil
            card.photoData = photoData; card.logoData = logoData
            repository.updateCard(card)
        } else {
            let newCard = BusinessCard(
                fullName: fullName, title: title, company: company,
                phone: phone, email: email, website: website,
                bio: bio, location: location, socialLinks: socialLinks,
                themeId: themeId, customTheme: isCustomTheme ? customTheme : nil,
                photoData: photoData, logoData: logoData,
                isCustomTheme: isCustomTheme
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
            Text(label).font(VYRISTypography.meta())
                .foregroundColor(VYRISColors.Semantic.textSecondary).tracking(0.5)
            TextField("", text: $text)
                .font(VYRISTypography.body())
                .foregroundColor(VYRISColors.Semantic.textPrimary)
                .keyboardType(keyboardType).autocorrectionDisabled()
                .textInputAutocapitalization(keyboardType == .default ? .words : .never)
                .padding(.vertical, VYRISSpacing.xs)
                .overlay(VYRISDivider(), alignment: .bottom)
        }
    }
}
