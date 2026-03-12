import SwiftUI

struct ContentView: View {
    @Environment(VehicleStore.self) private var store
    @Environment(VehicleViewModel.self) private var viewModel
    @Environment(StoreKitManager.self) private var storeKit

    @State private var showOnboarding = false
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                // Home / Check tab
                NavigationStack {
                    homeTab
                }
                .tabItem {
                    Label("Check", systemImage: "checkmark.shield.fill")
                }
                .tag(0)

                // Garage tab
                NavigationStack {
                    SavedVehiclesView()
                }
                .tabItem {
                    Label("Garage", systemImage: "car.2.fill")
                }
                .tag(1)

                // About / More tab
                NavigationStack {
                    aboutTab
                }
                .tabItem {
                    Label("About", systemImage: "info.circle.fill")
                }
                .tag(2)
            }
            .tint(TCTheme.accent)

            // Save toast
            if viewModel.showSaveToast {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(TCTheme.good)
                        Text("Saved to Garage")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(TCTheme.text)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(TCTheme.panel)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(TCTheme.good.opacity(0.3), lineWidth: 1))
                    .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            configureTabBar()
            if !store.hasShownOnboarding {
                showOnboarding = true
                store.markOnboardingShown()
            }
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView()
        }
        .sheet(isPresented: Binding(
            get: { viewModel.showWizard },
            set: { viewModel.showWizard = $0 }
        )) {
            DealCheckWizardView()
        }
    }

    // MARK: - Home Tab

    private var homeTab: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()

            if viewModel.showResults {
                VStack(spacing: 0) {
                    headerBar
                        .padding(.bottom, 8)
                    VerdictView()
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            viewModel.showResults = false
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 13))
                            Text("Check Another Deal")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(TCTheme.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(TCTheme.panelAlt)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(TCTheme.accent.opacity(0.3), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                    .accessibilityLabel("Check another deal")
                }
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        headerBar
                        homeDashboard
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Home Dashboard

    private var homeDashboard: some View {
        VStack(spacing: 20) {
            // Primary CTA
            Button {
                viewModel.reset()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    viewModel.showWizard = true
                }
            } label: {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Check a Deal")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Guided 4-step Deal Check wizard")
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .padding(20)
                .background(TCTheme.accentGradient)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: TCTheme.accent.opacity(0.35), radius: 16, y: 8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .accessibilityLabel("Check a deal. Opens guided 4-step wizard.")

            // Secondary actions
            HStack(spacing: 12) {
                NavigationLink {
                    AffordabilityView()
                } label: {
                    VStack(spacing: 10) {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(TCTheme.accent2)
                        Text("Affordability\nMode")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(TCTheme.text)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(TCTheme.accent2.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(TCTheme.accent2.opacity(0.25), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Affordability Mode — find your maximum vehicle budget")

                // Quick re-check of last result
                Button {
                    if viewModel.result != nil {
                        viewModel.showResults = true
                    } else {
                        viewModel.recalculate()
                        viewModel.showResults = true
                    }
                } label: {
                    VStack(spacing: 10) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(TCTheme.good)
                        Text("Last\nVerdict")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(TCTheme.text)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(TCTheme.good.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(TCTheme.good.opacity(0.2), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Show last verdict")
            }
            .padding(.horizontal, 16)

            // Recent saved vehicles preview
            if !store.savedVehicles.isEmpty {
                recentVehiclesSection
            }
        }
    }

    private var recentVehiclesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Vehicles")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(TCTheme.text)
                Spacer()
                Button {
                    selectedTab = 1
                } label: {
                    Text("See All")
                        .font(.system(size: 13))
                        .foregroundStyle(TCTheme.accent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("See all saved vehicles")
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.savedVehicles.prefix(5)) { vehicle in
                        recentVehicleCard(vehicle)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func recentVehicleCard(_ vehicle: Vehicle) -> some View {
        Button {
            viewModel.loadVehicle(vehicle)
            selectedTab = 0
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(TCTheme.accent)
                    Text(vehicle.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(TCTheme.text)
                        .lineLimit(1)
                }
                let r = CostCalculator.calculate(for: vehicle)
                Text(TCTheme.formatCurrency(r.trueMonthlyCost, symbol: viewModel.currencySymbol) + "/mo")
                    .font(.system(size: 15, weight: .black, design: .monospaced))
                    .foregroundStyle(TCTheme.accent)
                Text(r.verdict.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(verdictColor(r.verdict))
            }
            .padding(14)
            .frame(width: 160, alignment: .leading)
            .background(TCTheme.panel.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(TCTheme.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(vehicle.name). Load this vehicle.")
    }

    // MARK: - About Tab

    private var aboutTab: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()
            List {
                Section {
                    NavigationLink {
                        MethodologyView()
                    } label: {
                        Label("Methodology & Formulas", systemImage: "doc.text.magnifyingglass")
                    }
                    .accessibilityLabel("Methodology and formulas used by TrueCost Auto")
                } header: {
                    Text("Transparency")
                }

                Section {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                } header: {
                    Text("App")
                }

                Section {
                    HStack {
                        Text("Version")
                            .foregroundStyle(TCTheme.muted)
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(TCTheme.muted)
                            .font(.system(size: 13, design: .monospaced))
                    }
                    HStack {
                        Text("DealFit Index™")
                            .foregroundStyle(TCTheme.muted)
                        Spacer()
                        Text("Proprietary Score")
                            .foregroundStyle(TCTheme.accent)
                            .font(.system(size: 12))
                    }
                } header: {
                    Text("About")
                } footer: {
                    Text("TrueCost Auto is not a financial advisor. All figures are estimates for informational purposes only.")
                        .font(.system(size: 12))
                        .foregroundStyle(TCTheme.muted)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        AppLogo(size: 24)
                        Text("TrueCost Auto")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(TCTheme.text)
                    }
                }
            }
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(spacing: 12) {
            AppLogo(size: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text("TrueCost Auto")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(TCTheme.text)
                Text("Deal Verdict & DealFit Index™")
                    .font(.system(size: 11))
                    .foregroundStyle(TCTheme.muted)
            }

            Spacer()

            // Currency toggle
            Menu {
                ForEach(CurrencyRegion.allCases, id: \.self) { region in
                    Button {
                        viewModel.setCurrency(region)
                    } label: {
                        HStack {
                            Text(region.rawValue)
                            if viewModel.currency == region {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Text(viewModel.currency.rawValue)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(TCTheme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(TCTheme.accent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(TCTheme.accent.opacity(0.2), lineWidth: 1))
            }
            .accessibilityLabel("Currency: \(viewModel.currency.rawValue)")
            .accessibilityHint("Tap to change currency region")

            if viewModel.showResults {
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    viewModel.reset()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        viewModel.showWizard = true
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(TCTheme.accent)
                }
                .accessibilityLabel("New deal check")
                .accessibilityHint("Start a new deal check wizard")
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        ZStack {
            TCTheme.bg
            RadialGradient(
                colors: [TCTheme.accent.opacity(0.07), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 500
            )
        }
    }

    // MARK: - Tab Bar Config

    private func configureTabBar() {
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(TCTheme.bg)
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }

    // MARK: - Helpers

    private func verdictColor(_ v: VerdictRating) -> Color {
        switch v {
        case .good: return TCTheme.good
        case .caution: return TCTheme.warn
        case .notRecommended: return TCTheme.bad
        }
    }
}

#Preview {
    ContentView()
        .environment(VehicleStore())
        .environment(VehicleViewModel())
        .environment(StoreKitManager())
        .preferredColorScheme(.dark)
}
