import SwiftUI

struct ContentView: View {
    @Environment(VehicleStore.self) private var store
    @Environment(VehicleViewModel.self) private var viewModel
    @State private var showOnboarding = false
    @State private var selectedTab: Tab = .calculator

    enum Tab: String, CaseIterable {
        case calculator = "Calculator"
        case saved = "Saved"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

                TabView(selection: $selectedTab) {
                    calculatorView
                        .tag(Tab.calculator)
                        .tabItem {
                            Label("Calculator", systemImage: "function")
                        }

                    SavedVehiclesView()
                        .tag(Tab.saved)
                        .tabItem {
                            Label("Saved", systemImage: "bookmark.fill")
                        }
                }
                .tint(TCTheme.accent)

                // Save toast overlay
                if viewModel.showSaveToast {
                    VStack {
                        saveToast
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(100)
                }
            }
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView()
        }
        .onAppear {
            configureTabBarAppearance()
            if !store.hasShownOnboarding {
                showOnboarding = true
                store.markOnboardingShown()
            }
        }
    }

    @ViewBuilder
    private var calculatorView: some View {
        ScrollView {
            VStack(spacing: 18) {
                headerBar

                if viewModel.showResults, viewModel.result != nil {
                    ResultsView()
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    VehicleInputView()
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.interactively)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.showResults)
    }

    private var headerBar: some View {
        HStack(spacing: 12) {
            // Logo
            AppLogo(size: 42)
                .shadow(color: TCTheme.accent.opacity(0.18), radius: 10, y: 5)

            VStack(alignment: .leading, spacing: 2) {
                Text("TrueCost Auto")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(TCTheme.text)
                Text("See the real monthly cost.")
                    .font(.system(size: 12))
                    .foregroundStyle(TCTheme.muted)
            }

            Spacer()

            // Currency toggle
            currencyToggle

            if viewModel.showResults {
                Button {
                    viewModel.showResults = false
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Edit")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(TCTheme.panelAlt.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(TCTheme.line, lineWidth: 1)
                    )
                }
                .tint(TCTheme.text)
            }
        }
        .padding(16)
        .background(TCTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(TCTheme.line, lineWidth: 1)
        )
    }

    private var currencyToggle: some View {
        HStack(spacing: 0) {
            ForEach(CurrencyRegion.allCases, id: \.self) { region in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.setCurrency(region)
                    }
                } label: {
                    Text(region.symbol)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(viewModel.currency == region ? .white : TCTheme.muted)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            viewModel.currency == region
                                ? AnyShapeStyle(TCTheme.accentGradient)
                                : AnyShapeStyle(Color.clear)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(TCTheme.panelAlt.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(TCTheme.line, lineWidth: 1)
        )
    }

    private var saveToast: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(.white)
            Text("Vehicle Saved!")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(
            Capsule()
                .fill(TCTheme.good)
                .shadow(color: TCTheme.good.opacity(0.3), radius: 12, y: 4)
        )
        .padding(.top, 8)
    }

    private var backgroundGradient: some View {
        ZStack {
            TCTheme.bg
            RadialGradient(
                colors: [TCTheme.accent.opacity(0.15), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 600
            )
            RadialGradient(
                colors: [TCTheme.accent2.opacity(0.12), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 500
            )
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(TCTheme.panel.opacity(0.95))
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(TCTheme.muted)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(TCTheme.muted)
        ]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
        .environment(VehicleStore())
        .environment(VehicleViewModel())
}
