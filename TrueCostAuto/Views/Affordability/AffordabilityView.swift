import SwiftUI

/// Reverse affordability mode: the user enters a target monthly budget,
/// and the app computes the maximum vehicle price they can afford.
struct AffordabilityView: View {
    @Environment(VehicleViewModel.self) private var vm
    @State private var hasCalculated = false
    @State private var animate = false

    var body: some View {
        ZStack {
            TCTheme.bg.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(TCTheme.accent2)
                            Text("Affordability Mode")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(TCTheme.text)
                        }
                        Text("Enter your monthly budget and we'll compute the maximum vehicle price you can afford.")
                            .font(.system(size: 13))
                            .foregroundStyle(TCTheme.muted)
                            .lineSpacing(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Budget input card
                    inputCard

                    // Calculate button
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        vm.recalculateAffordability()
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            hasCalculated = true
                            animate = true
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                                .font(.system(size: 16))
                            Text("Calculate Max Budget")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(TCTheme.accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: TCTheme.accent.opacity(0.3), radius: 12, y: 6)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Calculate maximum vehicle budget")

                    // Results
                    if hasCalculated, let result = vm.affordabilityResult {
                        affordabilityResults(result)
                            .opacity(animate ? 1 : 0)
                            .offset(y: animate ? 0 : 20)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: animate)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Input Card

    private var inputCard: some View {
        @Bindable var vm = vm
        return VStack(spacing: 14) {
            inputRow(title: "Monthly Budget", icon: "dollarsign.circle.fill") {
                CurrencyField(value: $vm.affordabilityBudget, placeholder: "e.g. 800", unit: vm.currencySymbol + "/mo")
            }

            inputRow(title: "APR", icon: "percent") {
                PercentField(value: $vm.affordabilityAPR, placeholder: "6.99")
            }

            inputRow(title: "Loan Term", icon: "calendar") {
                TermPicker(selection: $vm.affordabilityTerm)
            }

            HStack(spacing: 12) {
                inputRow(title: "Down Payment", icon: "arrow.down.circle.fill") {
                    CurrencyField(value: $vm.affordabilityDownPayment, placeholder: "0", unit: vm.currencySymbol)
                }
                inputRow(title: "Trade-In", icon: "arrow.triangle.2.circlepath") {
                    CurrencyField(value: $vm.affordabilityTradeIn, placeholder: "0", unit: vm.currencySymbol)
                }
            }

            Divider().background(TCTheme.line)

            Text("Estimated Monthly Running Costs")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(TCTheme.muted)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                inputRow(title: "Insurance", icon: "shield.fill") {
                    CurrencyField(value: $vm.affordabilityInsurance, placeholder: "0", unit: vm.currencySymbol + "/mo")
                }
                inputRow(title: "Fuel", icon: "fuelpump.fill") {
                    CurrencyField(value: $vm.affordabilityFuel, placeholder: "0", unit: vm.currencySymbol + "/mo")
                }
            }
            HStack(spacing: 12) {
                inputRow(title: "Maintenance", icon: "wrench.fill") {
                    CurrencyField(value: $vm.affordabilityMaintenance, placeholder: "0", unit: vm.currencySymbol + "/mo")
                }
                inputRow(title: "Other", icon: "ellipsis.circle.fill") {
                    CurrencyField(value: $vm.affordabilityOther, placeholder: "0", unit: vm.currencySymbol + "/mo")
                }
            }
        }
        .padding(16)
        .tcCard()
    }

    @ViewBuilder
    private func inputRow<C: View>(title: String, icon: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(TCTheme.accent)
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(TCTheme.muted)
            }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Results

    private func affordabilityResults(_ result: AffordabilityResult) -> some View {
        VStack(spacing: 16) {
            // Hero: max vehicle price
            VStack(spacing: 6) {
                Text("Maximum Vehicle Price")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(TCTheme.muted)
                    .tracking(0.5)
                Text(TCTheme.formatCurrency(result.maxVehiclePrice, symbol: vm.currencySymbol))
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundStyle(TCTheme.accent)
                Text("before tax & dealer fees")
                    .font(.system(size: 12))
                    .foregroundStyle(TCTheme.muted)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(TCTheme.accent.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(TCTheme.accent.opacity(0.25), lineWidth: 1.5))

            // Breakdown
            VStack(spacing: 10) {
                resultRow(label: "Your monthly budget", value: TCTheme.formatCurrency(result.targetMonthlyCost, symbol: vm.currencySymbol) + "/mo")
                resultRow(label: "Est. running costs", value: "−\(TCTheme.formatCurrency(result.estimatedRunningCosts, symbol: vm.currencySymbol))/mo")
                Divider().background(TCTheme.line)
                resultRow(label: "Available for loan payment", value: TCTheme.formatCurrency(result.maxMonthlyLoanPayment, symbol: vm.currencySymbol) + "/mo", highlighted: true)
                resultRow(label: "Max financed amount", value: TCTheme.formatCurrency(result.maxFinancedAmount, symbol: vm.currencySymbol))
                resultRow(label: "Down payment + trade-in", value: "+\(TCTheme.formatCurrency(vm.affordabilityDownPayment + vm.affordabilityTradeIn, symbol: vm.currencySymbol))")
                Divider().background(TCTheme.line)
                resultRow(label: "Max vehicle price (est.)", value: TCTheme.formatCurrency(result.maxVehiclePrice, symbol: vm.currencySymbol), highlighted: true)

                if let pct = result.incomePercent {
                    Divider().background(TCTheme.line)
                    HStack {
                        Text("Budget as % of income")
                            .font(.system(size: 13))
                            .foregroundStyle(TCTheme.muted)
                        Spacer()
                        Text(String(format: "%.1f%%", pct))
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundStyle(pct < 20 ? TCTheme.good : pct < 30 ? TCTheme.warn : TCTheme.bad)
                    }
                }
            }
            .padding(16)
            .tcCard()

            // Disclaimer
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(TCTheme.accent.opacity(0.7))
                Text("This estimate assumes your budget covers loan payment + running costs only. It does not include a depreciation reserve. See Methodology for formula details.")
                    .font(.system(size: 12))
                    .foregroundStyle(TCTheme.muted)
                    .lineSpacing(2)
            }
            .padding(12)
            .background(TCTheme.accent.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func resultRow(label: String, value: String, highlighted: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: highlighted ? 14 : 13, weight: highlighted ? .semibold : .regular))
                .foregroundStyle(highlighted ? TCTheme.text : TCTheme.muted)
            Spacer()
            Text(value)
                .font(.system(size: highlighted ? 15 : 13, weight: highlighted ? .bold : .semibold, design: .monospaced))
                .foregroundStyle(highlighted ? TCTheme.accent : TCTheme.text)
        }
    }
}

#Preview {
    AffordabilityView()
        .environment(VehicleViewModel())
        .preferredColorScheme(.dark)
}
