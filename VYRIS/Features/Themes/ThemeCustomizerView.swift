import SwiftUI

// MARK: - Theme Customizer
// Full visual theme editor — users can customize every aspect of their card.

struct ThemeCustomizerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var customTheme: CustomThemeData
    @Binding var isCustom: Bool
    @Binding var presetThemeId: String
    let card: BusinessCard

    @State private var activeSection: CustomizerSection = .colors
    @State private var showColorPicker = false
    @State private var editingColorBinding: ColorTarget = .background

    private var previewTheme: CardTheme {
        if isCustom {
            return CardTheme.fromCustom(customTheme, id: "preview")
        }
        return ThemeRegistry.theme(for: presetThemeId)
    }

    enum CustomizerSection: String, CaseIterable {
        case presets
        case colors
        case layout
        case style
        case decoration

        var localizationKey: LocalizedStringKey {
            switch self {
            case .presets: return "customizer.presets"
            case .colors: return "customizer.colors"
            case .layout: return "customizer.layout"
            case .style: return "customizer.style"
            case .decoration: return "customizer.decoration"
            }
        }
    }

    enum ColorTarget {
        case background, secondaryBg, text, secondaryText, accent, stroke
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VYRISColors.Semantic.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Live card preview
                    CardFrontView(
                        card: card,
                        theme: previewTheme,
                        tiltX: 0, tiltY: 0,
                        motionEnabled: false
                    )
                    .padding(.horizontal, VYRISSpacing.xl)
                    .padding(.top, VYRISSpacing.sm)
                    .vyrisShadow(VYRISShadow.cardResting)

                    // Section tabs
                    sectionTabs
                        .padding(.top, VYRISSpacing.md)

                    VYRISDivider().padding(.horizontal, VYRISSpacing.lg)

                    // Section content
                    ScrollView {
                        sectionContent
                            .padding(.horizontal, VYRISSpacing.lg)
                            .padding(.vertical, VYRISSpacing.md)
                    }
                }
            }
            .navigationTitle(Text("customizer.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Text("common.cancel").font(VYRISTypography.body())
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button { dismiss() } label: {
                        Text("common.done")
                            .font(VYRISTypography.button())
                            .foregroundColor(VYRISColors.Semantic.accent)
                    }
                }
            }
            .sheet(isPresented: $showColorPicker) {
                ColorPickerSheet(
                    target: editingColorBinding,
                    customTheme: $customTheme
                )
            }
        }
    }

    // MARK: - Section Tabs

    private var sectionTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: VYRISSpacing.sm) {
                ForEach(CustomizerSection.allCases, id: \.rawValue) { section in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            activeSection = section
                        }
                    } label: {
                        Text(section.localizationKey)
                            .font(VYRISTypography.meta())
                            .foregroundColor(
                                activeSection == section
                                ? VYRISColors.Semantic.accent
                                : VYRISColors.Semantic.textSecondary
                            )
                            .padding(.horizontal, VYRISSpacing.sm)
                            .padding(.vertical, VYRISSpacing.xxs)
                            .background(
                                activeSection == section
                                ? VYRISColors.Semantic.accent.opacity(0.1)
                                : Color.clear
                            )
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, VYRISSpacing.lg)
        }
    }

    // MARK: - Section Content

    @ViewBuilder
    private var sectionContent: some View {
        switch activeSection {
        case .presets:
            presetsSection
        case .colors:
            colorsSection
        case .layout:
            layoutSection
        case .style:
            styleSection
        case .decoration:
            decorationSection
        }
    }

    // MARK: - Presets

    private var presetsSection: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: VYRISSpacing.sm)],
                  spacing: VYRISSpacing.sm) {
            ForEach(ThemeRegistry.allThemes) { theme in
                presetCell(theme)
            }
        }
    }

    private func presetCell(_ theme: CardTheme) -> some View {
        let selected = !isCustom && presetThemeId == theme.id
        return VStack(spacing: VYRISSpacing.xxs) {
            RoundedRectangle(cornerRadius: 10)
                .fill(theme.backgroundColor)
                .aspectRatio(VYRISCardDimensions.aspectRatio, contentMode: .fit)
                .overlay(
                    VStack(spacing: 2) {
                        Circle().fill(theme.accentColor).frame(width: 8, height: 8)
                        RoundedRectangle(cornerRadius: 1)
                            .fill(theme.textColor.opacity(0.5))
                            .frame(width: 30, height: 3)
                        RoundedRectangle(cornerRadius: 1)
                            .fill(theme.secondaryTextColor.opacity(0.3))
                            .frame(width: 22, height: 2)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(selected ? VYRISColors.Semantic.accent : theme.strokeColor,
                                      lineWidth: selected ? 2 : 0.5)
                )

            Text(theme.displayName)
                .font(VYRISTypography.caption())
                .foregroundColor(selected ? VYRISColors.Semantic.textPrimary : VYRISColors.Semantic.textSecondary)
                .lineLimit(1)
        }
        .onTapGesture {
            VYRISHaptics.selection()
            isCustom = false
            presetThemeId = theme.id
        }
    }

    // MARK: - Colors

    private var colorsSection: some View {
        VStack(spacing: VYRISSpacing.md) {
            colorRow("customizer.color.background", hex: customTheme.backgroundColorHex, target: .background)
            colorRow("customizer.color.secondaryBg", hex: customTheme.secondaryBackgroundHex ?? "EEEEEE", target: .secondaryBg)
            colorRow("customizer.color.text", hex: customTheme.textColorHex, target: .text)
            colorRow("customizer.color.secondaryText", hex: customTheme.secondaryTextColorHex, target: .secondaryText)
            colorRow("customizer.color.accent", hex: customTheme.accentColorHex, target: .accent)
            colorRow("customizer.color.stroke", hex: customTheme.strokeColorHex, target: .stroke)

            // Stroke width slider
            VStack(alignment: .leading, spacing: VYRISSpacing.xxs) {
                Text("customizer.color.strokeWidth")
                    .font(VYRISTypography.meta())
                    .foregroundColor(VYRISColors.Semantic.textSecondary)
                Slider(value: Binding(
                    get: { customTheme.strokeWidth },
                    set: { customTheme.strokeWidth = $0; isCustom = true }
                ), in: 0...3, step: 0.5)
                .tint(VYRISColors.Semantic.accent)
            }
        }
    }

    private func colorRow(_ label: LocalizedStringKey, hex: String, target: ColorTarget) -> some View {
        Button {
            editingColorBinding = target
            isCustom = true
            showColorPicker = true
        } label: {
            HStack {
                Text(label)
                    .font(VYRISTypography.body())
                    .foregroundColor(VYRISColors.Semantic.textPrimary)
                Spacer()
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hexString: hex))
                    .frame(width: 36, height: 24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(VYRISColors.Semantic.stroke, lineWidth: 0.5)
                    )
                Text("#\(hex)")
                    .font(VYRISTypography.meta())
                    .foregroundColor(VYRISColors.Semantic.textSecondary)
                    .frame(width: 70, alignment: .trailing)
            }
        }
    }

    // MARK: - Layout

    private var layoutSection: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: VYRISSpacing.xs)],
                  spacing: VYRISSpacing.xs) {
            ForEach(CardLayoutStyle.allCases) { layout in
                let selected = customTheme.layoutStyle == layout.rawValue
                Button {
                    VYRISHaptics.selection()
                    customTheme.layoutStyle = layout.rawValue
                    isCustom = true
                } label: {
                    VStack(spacing: VYRISSpacing.xxs) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(selected ? VYRISColors.Semantic.accent.opacity(0.15) : VYRISColors.Semantic.backgroundSecondary)
                            .frame(height: 44)
                            .overlay(
                                Text(layout.rawValue.prefix(3).uppercased())
                                    .font(VYRISTypography.caption())
                                    .foregroundColor(selected ? VYRISColors.Semantic.accent : VYRISColors.Semantic.textSecondary)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(selected ? VYRISColors.Semantic.accent : Color.clear, lineWidth: 1)
                            )
                        Text(layout.displayName)
                            .font(.system(size: 9))
                            .foregroundColor(VYRISColors.Semantic.textSecondary)
                            .lineLimit(1)
                    }
                }
            }
        }
    }

    // MARK: - Style (Font + Background)

    private var styleSection: some View {
        VStack(alignment: .leading, spacing: VYRISSpacing.lg) {
            // Font styles
            VStack(alignment: .leading, spacing: VYRISSpacing.sm) {
                Text("customizer.fontStyle")
                    .font(VYRISTypography.meta())
                    .foregroundColor(VYRISColors.Semantic.textSecondary)
                    .tracking(1).textCase(.uppercase)

                HStack(spacing: VYRISSpacing.sm) {
                    ForEach(CardFontStyle.allCases) { font in
                        let selected = customTheme.fontStyle == font.rawValue
                        Button {
                            VYRISHaptics.selection()
                            customTheme.fontStyle = font.rawValue
                            isCustom = true
                        } label: {
                            VStack(spacing: VYRISSpacing.xxs) {
                                Text("Aa")
                                    .font(font.nameFont(18))
                                    .foregroundColor(selected ? VYRISColors.Semantic.accent : VYRISColors.Semantic.textPrimary)
                                Text(font.displayName)
                                    .font(.system(size: 9))
                                    .foregroundColor(VYRISColors.Semantic.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, VYRISSpacing.xs)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selected ? VYRISColors.Semantic.accent.opacity(0.1) : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(selected ? VYRISColors.Semantic.accent : VYRISColors.Semantic.stroke,
                                                  lineWidth: selected ? 1 : 0.5)
                            )
                        }
                    }
                }
            }

            // Background styles
            VStack(alignment: .leading, spacing: VYRISSpacing.sm) {
                Text("customizer.backgroundStyle")
                    .font(VYRISTypography.meta())
                    .foregroundColor(VYRISColors.Semantic.textSecondary)
                    .tracking(1).textCase(.uppercase)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: VYRISSpacing.sm)],
                          spacing: VYRISSpacing.sm) {
                    ForEach(CardBackgroundStyle.allCases) { bg in
                        let selected = customTheme.backgroundStyle == bg.rawValue
                        Button {
                            VYRISHaptics.selection()
                            customTheme.backgroundStyle = bg.rawValue
                            isCustom = true
                        } label: {
                            Text(bg.displayName)
                                .font(VYRISTypography.caption())
                                .foregroundColor(selected ? VYRISColors.Semantic.accent : VYRISColors.Semantic.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, VYRISSpacing.xs)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selected ? VYRISColors.Semantic.accent.opacity(0.1) : VYRISColors.Semantic.backgroundSecondary)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(selected ? VYRISColors.Semantic.accent : Color.clear, lineWidth: 1)
                                )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Decoration

    private var decorationSection: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: VYRISSpacing.sm)],
                  spacing: VYRISSpacing.sm) {
            ForEach(DecorationStyle.allCases) { deco in
                let selected = customTheme.decorationStyle == deco.rawValue
                Button {
                    VYRISHaptics.selection()
                    customTheme.decorationStyle = deco.rawValue
                    isCustom = true
                } label: {
                    VStack(spacing: VYRISSpacing.xxs) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(VYRISColors.Semantic.backgroundSecondary)
                            .frame(height: 50)
                            .overlay(
                                CardDecorationView(
                                    style: deco,
                                    accentColor: VYRISColors.Semantic.accent,
                                    secondaryColor: VYRISColors.Semantic.textSecondary
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(selected ? VYRISColors.Semantic.accent : VYRISColors.Semantic.stroke,
                                                  lineWidth: selected ? 1.5 : 0.5)
                            )
                        Text(deco.displayName)
                            .font(.system(size: 9))
                            .foregroundColor(VYRISColors.Semantic.textSecondary)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
}

// MARK: - Color Picker Sheet

struct ColorPickerSheet: View {
    let target: ThemeCustomizerView.ColorTarget
    @Binding var customTheme: CustomThemeData
    @Environment(\.dismiss) private var dismiss

    @State private var selectedColor: Color = .white

    var body: some View {
        NavigationStack {
            VStack(spacing: VYRISSpacing.lg) {
                ColorPicker("Select Color", selection: $selectedColor, supportsOpacity: false)
                    .labelsHidden()
                    .scaleEffect(1.5)
                    .padding(.top, VYRISSpacing.xxl)

                // Preset swatches
                presetSwatches

                Spacer()
            }
            .padding(VYRISSpacing.lg)
            .navigationTitle(Text("customizer.chooseColor"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        applyColor()
                        dismiss()
                    } label: {
                        Text("common.done")
                            .font(VYRISTypography.button())
                            .foregroundColor(VYRISColors.Semantic.accent)
                    }
                }
            }
            .onAppear { loadCurrentColor() }
        }
        .presentationDetents([.medium])
    }

    private var presetSwatches: some View {
        let swatches: [UInt] = [
            0xF4F1EB, 0x1C1C1E, 0x0C0C0E, 0x0D1B1E, 0x0A1628,
            0xC6A96B, 0xD4AF37, 0x00E5A0, 0xFF6B5A, 0xB8960C,
            0x8B5CF6, 0x1B5E20, 0xC1613D, 0xFF2D78, 0xFF0000,
            0xC4846C, 0x4A9CC9, 0xFFFFFF, 0x000000, 0xF5EBE0
        ]
        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 44), spacing: VYRISSpacing.xs)],
                         spacing: VYRISSpacing.xs) {
            ForEach(swatches, id: \.self) { hex in
                Circle()
                    .fill(Color(hex: hex))
                    .frame(width: 40, height: 40)
                    .overlay(Circle().strokeBorder(Color.gray.opacity(0.2), lineWidth: 0.5))
                    .onTapGesture {
                        selectedColor = Color(hex: hex)
                    }
            }
        }
    }

    private func loadCurrentColor() {
        let hex: String
        switch target {
        case .background: hex = customTheme.backgroundColorHex
        case .secondaryBg: hex = customTheme.secondaryBackgroundHex ?? "EEEEEE"
        case .text: hex = customTheme.textColorHex
        case .secondaryText: hex = customTheme.secondaryTextColorHex
        case .accent: hex = customTheme.accentColorHex
        case .stroke: hex = customTheme.strokeColorHex
        }
        selectedColor = Color(hexString: hex)
    }

    private func applyColor() {
        let hexStr = selectedColor.toHexString()
        switch target {
        case .background: customTheme.backgroundColorHex = hexStr
        case .secondaryBg: customTheme.secondaryBackgroundHex = hexStr
        case .text: customTheme.textColorHex = hexStr
        case .secondaryText: customTheme.secondaryTextColorHex = hexStr
        case .accent: customTheme.accentColorHex = hexStr
        case .stroke: customTheme.strokeColorHex = hexStr
        }
    }
}

// MARK: - Color to Hex String

extension Color {
    func toHexString() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
