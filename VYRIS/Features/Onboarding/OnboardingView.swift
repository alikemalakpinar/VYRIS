import SwiftUI

// MARK: - Onboarding Flow
// 3 screens with localized content, clean minimal animated transitions.

struct OnboardingView: View {
    @State private var currentPage = 0
    let onComplete: () -> Void

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            titleKey: "onboarding.screen1.title",
            subtitleKey: "onboarding.screen1.subtitle",
            symbolName: "person.text.rectangle"
        ),
        OnboardingPage(
            titleKey: "onboarding.screen2.title",
            subtitleKey: "onboarding.screen2.subtitle",
            symbolName: "crown"
        ),
        OnboardingPage(
            titleKey: "onboarding.screen3.title",
            subtitleKey: "onboarding.screen3.subtitle",
            symbolName: "hand.raised"
        )
    ]

    var body: some View {
        ZStack {
            VYRISBackground()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button {
                            onComplete()
                        } label: {
                            Text("onboarding.skip")
                                .font(VYRISTypography.meta())
                                .foregroundColor(VYRISColors.Semantic.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, VYRISSpacing.lg)
                .padding(.top, VYRISSpacing.sm)
                .frame(height: 44)

                Spacer()

                // Content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                Spacer()

                // Page indicators
                pageIndicators
                    .padding(.bottom, VYRISSpacing.xl)

                // Action button
                actionButton
                    .padding(.horizontal, VYRISSpacing.xl)
                    .padding(.bottom, VYRISSpacing.xxl)
            }
        }
    }

    // MARK: - Page Indicators

    private var pageIndicators: some View {
        HStack(spacing: VYRISSpacing.xs) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage
                          ? VYRISColors.Semantic.accent
                          : VYRISColors.Semantic.stroke)
                    .frame(width: index == currentPage ? 24 : 8, height: 3)
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
            }
        }
    }

    // MARK: - Action Button

    private var actionButton: some View {
        Button {
            if currentPage < pages.count - 1 {
                withAnimation(.easeInOut(duration: 0.4)) {
                    currentPage += 1
                }
            } else {
                onComplete()
            }
        } label: {
            Text(currentPage < pages.count - 1 ? "onboarding.next" : "onboarding.getStarted")
                .font(VYRISTypography.button())
                .foregroundColor(VYRISColors.Semantic.backgroundPrimary)
                .tracking(1.5)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity)
                .padding(.vertical, VYRISSpacing.md)
                .background(
                    Capsule()
                        .fill(VYRISColors.Semantic.textPrimary)
                )
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let titleKey: LocalizedStringKey
    let subtitleKey: LocalizedStringKey
    let symbolName: String
}

// MARK: - Single Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var appeared = false

    var body: some View {
        VStack(spacing: VYRISSpacing.lg) {
            Image(systemName: page.symbolName)
                .font(.system(size: 40, weight: .ultraLight))
                .foregroundColor(VYRISColors.Semantic.accent)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

            VStack(spacing: VYRISSpacing.sm) {
                Text(page.titleKey)
                    .font(VYRISTypography.displayLarge())
                    .foregroundColor(VYRISColors.Semantic.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 15)

                Text(page.subtitleKey)
                    .font(VYRISTypography.body())
                    .foregroundColor(VYRISColors.Semantic.textSecondary)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)
            }
            .padding(.horizontal, VYRISSpacing.xl)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
        }
        .onDisappear {
            appeared = false
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(onComplete: {})
}
