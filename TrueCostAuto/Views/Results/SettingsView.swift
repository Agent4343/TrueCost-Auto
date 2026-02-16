import SwiftUI

struct SettingsView: View {
    @Environment(VehicleViewModel.self) private var viewModel
    @Environment(VehicleStore.self) private var store
    @State private var showResetAlert = false

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Currency
                    currencySection

                    // App info
                    aboutSection

                    // Data management
                    dataSection
                }
                .padding(16)
            }
        }
        .navigationTitle("Settings")
        .alert("Reset All Data?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                store.deleteAll()
                viewModel.reset()
            }
        } message: {
            Text("This will delete all saved vehicles and reset the calculator. This cannot be undone.")
        }
    }

    // MARK: - Currency Section
    private var currencySection: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundStyle(TCTheme.accent)
                    Text("Currency & Region")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(TCTheme.text)
                }
                Spacer()
            }
            .padding(14)
            .background(TCTheme.panelAlt.opacity(0.55))

            Divider().overlay(TCTheme.line)

            VStack(spacing: 12) {
                ForEach(CurrencyRegion.allCases, id: \.self) { region in
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        viewModel.setCurrency(region)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: viewModel.currency == region ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(viewModel.currency == region ? TCTheme.accent : TCTheme.muted)
                                .font(.system(size: 18))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(region.rawValue)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(TCTheme.text)
                                Text(currencyDescription(region))
                                    .font(.system(size: 11))
                                    .foregroundStyle(TCTheme.muted)
                            }

                            Spacer()

                            Text(region.symbol)
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundStyle(TCTheme.accent.opacity(0.7))
                        }
                        .padding(12)
                        .background(viewModel.currency == region ? TCTheme.accent.opacity(0.08) : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(region.rawValue)
                    .accessibilityAddTraits(viewModel.currency == region ? .isSelected : [])
                }
            }
            .padding(14)
        }
        .tcCard()
    }

    private func currencyDescription(_ region: CurrencyRegion) -> String {
        switch region {
        case .cad: return "Canadian Dollar \u{2022} Tax: \(Int(region.defaultTaxRate))% \u{2022} L/100km"
        case .usd: return "US Dollar \u{2022} Tax: \(Int(region.defaultTaxRate))% \u{2022} MPG"
        }
    }

    // MARK: - About Section
    private var aboutSection: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(TCTheme.accent2)
                    Text("About")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(TCTheme.text)
                }
                Spacer()
            }
            .padding(14)
            .background(TCTheme.panelAlt.opacity(0.55))

            Divider().overlay(TCTheme.line)

            VStack(spacing: 16) {
                HStack(spacing: 14) {
                    AppLogo(size: 52)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ShiftSync")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(TCTheme.text)
                        Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                            .font(.system(size: 12))
                            .foregroundStyle(TCTheme.muted)
                    }
                    Spacer()
                }

                Text("See the true cost of any vehicle — not just the sticker price. ShiftSync calculates your real monthly cost including loan payments, insurance, fuel, maintenance, and depreciation.")
                    .font(.system(size: 12))
                    .foregroundStyle(TCTheme.muted)
                    .lineSpacing(3)

                Divider().overlay(TCTheme.line)

                VStack(spacing: 8) {
                    infoRow("Smart Score", "Weighted algorithm based on income ratio, interest burden, and loan term")
                    infoRow("Depreciation", "Compound annual rate averaged over 5 years")
                    infoRow("Fuel Estimator", "Region-aware calculation using distance, efficiency, and fuel price")
                }

                Divider().overlay(TCTheme.line)

                // Financial disclaimer
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(TCTheme.warn)
                        Text("Disclaimer")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(TCTheme.muted)
                    }
                    Text("ShiftSync provides estimates for informational purposes only and does not constitute financial advice. Actual costs may vary based on lender terms, market conditions, and other factors. Always verify figures with your lender or financial advisor before making purchase decisions.")
                        .font(.system(size: 10))
                        .foregroundStyle(TCTheme.muted.opacity(0.7))
                        .lineSpacing(2)
                }
            }
            .padding(14)
        }
        .tcCard()
    }

    private func infoRow(_ title: String, _ description: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(TCTheme.accent.opacity(0.3))
                .frame(width: 6, height: 6)
                .padding(.top, 5)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(TCTheme.text)
                Text(description)
                    .font(.system(size: 11))
                    .foregroundStyle(TCTheme.muted)
            }
            Spacer()
        }
    }

    // MARK: - Data Section
    private var dataSection: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "externaldrive.fill")
                        .foregroundStyle(TCTheme.warn)
                    Text("Data")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(TCTheme.text)
                }
                Spacer()
            }
            .padding(14)
            .background(TCTheme.panelAlt.opacity(0.55))

            Divider().overlay(TCTheme.line)

            VStack(spacing: 12) {
                HStack {
                    Text("Saved Vehicles")
                        .font(.system(size: 13))
                        .foregroundStyle(TCTheme.muted)
                    Spacer()
                    Text("\(store.savedVehicles.count)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(TCTheme.text)
                }

                Button {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    showResetAlert = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "trash")
                            .font(.system(size: 13))
                        Text("Reset All Data")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(TCTheme.bad)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(TCTheme.bad.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(TCTheme.bad.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Reset all data")
                .accessibilityHint("Deletes all saved vehicles and resets the calculator")
            }
            .padding(14)
        }
        .tcCard()
    }

    private var backgroundGradient: some View {
        ZStack {
            TCTheme.bg
            RadialGradient(
                colors: [TCTheme.accent2.opacity(0.06), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 500
            )
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(VehicleViewModel())
    .environment(VehicleStore())
    .preferredColorScheme(.dark)
}
