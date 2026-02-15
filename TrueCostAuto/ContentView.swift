import SwiftUI

struct ContentView: View {
    @Environment(VehicleStore.self) private var store
    @Environment(VehicleViewModel.self) private var viewModel

    @State private var showOnboarding = false
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                // Calculator tab
                calculatorTab
                    .tabItem {
                        Image(systemName: "function")
                        Text("Calculator")
                    }
                    .tag(0)

                // Saved tab
                NavigationStack {
                    SavedVehiclesView()
                }
                .tabItem {
                    Image(systemName: "bookmark.fill")
                    Text("Saved")
                }
                .tag(1)

                // Settings tab
                NavigationStack {
                    SettingsView()
                }
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
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
                        Text("Vehicle saved")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(TCTheme.text)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(TCTheme.panel)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(TCTheme.good.opacity(0.3), lineWidth: 1)
                    )
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
    }

    // MARK: - Calculator Tab
    private var calculatorTab: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    headerBar

                    if viewModel.showResults {
                        ResultsView()

                        // Edit / recalculate
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                viewModel.showResults = false
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 13))
                                Text("Edit & Recalculate")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundStyle(TCTheme.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(TCTheme.panelAlt)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(TCTheme.accent.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        VehicleInputView()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Header
    private var headerBar: some View {
        HStack(spacing: 12) {
            AppLogo(size: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text("TrueCost Auto")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(TCTheme.text)
                Text("See the real cost")
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(TCTheme.accent.opacity(0.2), lineWidth: 1)
                    )
            }

            // New / edit toggle
            if viewModel.showResults {
                Button {
                    viewModel.reset()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(TCTheme.accent)
                }
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Background
    private var backgroundGradient: some View {
        ZStack {
            TCTheme.bg
            RadialGradient(
                colors: [TCTheme.accent.opacity(0.08), .clear],
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
}

#Preview {
    ContentView()
        .environment(VehicleStore())
        .environment(VehicleViewModel())
        .preferredColorScheme(.dark)
}
