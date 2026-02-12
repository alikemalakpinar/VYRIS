import SwiftUI

// MARK: - Settings Screen

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var settings: AppSettings
    @Bindable var localization: LocalizationManager

    var body: some View {
        NavigationStack {
            ZStack {
                VYRISColors.Semantic.backgroundPrimary
                    .ignoresSafeArea()

                List {
                    // Language
                    languageSection

                    // Motion
                    motionSection

                    // Appearance
                    appearanceSection

                    // About
                    aboutSection
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(Text("settings.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("common.done")
                            .font(VYRISTypography.button())
                            .foregroundColor(VYRISColors.Semantic.accent)
                    }
                }
            }
        }
    }

    // MARK: - Language

    private var languageSection: some View {
        Section {
            ForEach(AppLanguage.allCases) { language in
                Button {
                    VYRISHaptics.selection()
                    localization.currentLanguage = language
                } label: {
                    HStack {
                        Text(language.displayName)
                            .font(VYRISTypography.body())
                            .foregroundColor(VYRISColors.Semantic.textPrimary)

                        Spacer()

                        if localization.currentLanguage == language {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(VYRISColors.Semantic.accent)
                        }
                    }
                }
            }
        } header: {
            Text("settings.language")
                .font(VYRISTypography.meta())
                .foregroundColor(VYRISColors.Semantic.textSecondary)
                .tracking(1)
        }
    }

    // MARK: - Motion

    private var motionSection: some View {
        Section {
            Toggle(isOn: $settings.motionEnabled) {
                VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
                    Text("settings.motion")
                        .font(VYRISTypography.body())
                        .foregroundColor(VYRISColors.Semantic.textPrimary)

                    Text("settings.motionSubtitle")
                        .font(VYRISTypography.meta())
                        .foregroundColor(VYRISColors.Semantic.textSecondary)
                }
            }
            .tint(VYRISColors.Semantic.accent)
        }
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        Section {
            ForEach(AppearanceMode.allCases) { mode in
                Button {
                    VYRISHaptics.selection()
                    settings.appearanceMode = mode
                } label: {
                    HStack {
                        Text(mode.displayKey)
                            .font(VYRISTypography.body())
                            .foregroundColor(VYRISColors.Semantic.textPrimary)

                        Spacer()

                        if settings.appearanceMode == mode {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(VYRISColors.Semantic.accent)
                        }
                    }
                }
            }
        } header: {
            Text("settings.appearance")
                .font(VYRISTypography.meta())
                .foregroundColor(VYRISColors.Semantic.textSecondary)
                .tracking(1)
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section {
            NavigationLink {
                AboutView()
            } label: {
                Text("settings.about")
                    .font(VYRISTypography.body())
                    .foregroundColor(VYRISColors.Semantic.textPrimary)
            }

            NavigationLink {
                PrivacyView()
            } label: {
                Text("settings.privacy")
                    .font(VYRISTypography.body())
                    .foregroundColor(VYRISColors.Semantic.textPrimary)
            }

            HStack {
                Text("settings.version")
                    .font(VYRISTypography.body())
                    .foregroundColor(VYRISColors.Semantic.textPrimary)

                Spacer()

                Text(AppVersion.display)
                    .font(VYRISTypography.meta())
                    .foregroundColor(VYRISColors.Semantic.textSecondary)
            }
        }
    }
}

// MARK: - About View

struct AboutView: View {
    var body: some View {
        ZStack {
            VYRISColors.Semantic.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: VYRISSpacing.xl) {
                Spacer()

                VYRISBrandMark(size: 32)

                Text("about.tagline")
                    .font(VYRISTypography.body())
                    .foregroundColor(VYRISColors.Semantic.textSecondary)

                Spacer()

                VStack(spacing: VYRISSpacing.xs) {
                    Text("VYRIS \(AppVersion.display)")
                        .font(VYRISTypography.meta())
                        .foregroundColor(VYRISColors.Semantic.textSecondary)

                    Text("about.subtitle")
                        .font(VYRISTypography.caption())
                        .foregroundColor(VYRISColors.Semantic.textSecondary)
                }
                .padding(.bottom, VYRISSpacing.xl)
            }
        }
        .navigationTitle(Text("settings.about"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Privacy View

struct PrivacyView: View {
    var body: some View {
        ZStack {
            VYRISColors.Semantic.backgroundPrimary
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: VYRISSpacing.md) {
                    Text("privacy.title")
                        .font(VYRISTypography.title())
                        .foregroundColor(VYRISColors.Semantic.textPrimary)

                    Text("privacy.section1")
                        .font(VYRISTypography.body())
                        .foregroundColor(VYRISColors.Semantic.textSecondary)

                    Text("privacy.section2")
                        .font(VYRISTypography.body())
                        .foregroundColor(VYRISColors.Semantic.textSecondary)

                    Text("privacy.section3")
                        .font(VYRISTypography.body())
                        .foregroundColor(VYRISColors.Semantic.textSecondary)
                }
                .padding(VYRISSpacing.lg)
            }
        }
        .navigationTitle(Text("settings.privacy"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
