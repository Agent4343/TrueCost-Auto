import SwiftUI

struct ContentView: View {
    @Environment(VehicleStore.self) private var store
    @Environment(VehicleViewModel.self) private var viewModel
    @State private var showOnboarding = false
    @State private var showSavedVehicles = false
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
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(TCTheme.accentGradient)
                .frame(width: 42, height: 42)
                .overlay(
                    Text("TC")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                )
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
