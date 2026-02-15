import SwiftUI

struct LoanSection: View {
    @Environment(VehicleViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel

        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "banknote.fill")
                        .foregroundStyle(TCTheme.accent2)
                    Text("Loan Details")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(TCTheme.text)
                }
                Spacer()
            }
            .padding(14)
            .background(TCTheme.panelAlt.opacity(0.55))

            Divider()
                .overlay(TCTheme.line)

            VStack(spacing: 12) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    PercentField(
                        label: "Interest Rate (APR)",
                        value: $vm.vehicle.interestRate
                    )
                    PercentField(
                        label: "Sales Tax",
                        value: $vm.vehicle.salesTaxRate
                    )
                }

                TermPicker(
                    selectedTerm: $vm.vehicle.loanTermMonths,
                    terms: Vehicle.availableTerms
                )

                CurrencyField(
                    label: "Monthly Income (optional)",
                    unit: "$",
                    value: $vm.vehicle.monthlyIncome,
                    placeholder: "For Smart Score"
                )

                // Tips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        tipPill(icon: "calendar", text: "Bi-weekly view included")
                        tipPill(icon: "arrow.up.circle", text: "Extra payment scenarios")
                        tipPill(icon: "chart.line.uptrend.xyaxis", text: "Amortization breakdown")
                    }
                }
            }
            .padding(14)
        }
        .tcCard()
    }

    private func tipPill(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 11))
        }
        .foregroundStyle(TCTheme.muted)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(TCTheme.panelAlt.opacity(0.7))
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(TCTheme.line, lineWidth: 1)
        )
    }
}

#Preview {
    LoanSection()
        .padding()
        .background(TCTheme.bg)
        .environment(VehicleViewModel())
        .preferredColorScheme(.dark)
}
