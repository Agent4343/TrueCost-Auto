import SwiftUI

struct ExtraPaymentView: View {
    @Environment(VehicleViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    @State private var extraAmount: Double = 100
    @State private var extraResult: CalculationResult?

    var body: some View {
        NavigationStack {
            ZStack {
                TCTheme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        explanationCard

                        // Extra payment input
                        inputSection

                        // Results
                        if let extraResult = extraResult, let baseResult = viewModel.result {
                            resultsSection(base: baseResult, extra: extraResult)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Extra Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .tint(TCTheme.accent)
                }
            }
            .onAppear {
                recalculate()
            }
        }
        .preferredColorScheme(.dark)
    }

    private var explanationCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(TCTheme.warn)
                Text("What if you paid extra each month?")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(TCTheme.text)
            }
            Text("Adding even a small extra amount to your monthly payment can save you thousands in interest and months off your loan.")
                .font(.system(size: 12))
                .foregroundStyle(TCTheme.muted)
                .lineSpacing(2)
        }
        .padding(14)
        .tcCard()
    }

    private var inputSection: some View {
        VStack(spacing: 12) {
            CurrencyField(
                label: "Extra Monthly Payment",
                unit: "$/mo",
                value: $extraAmount
            )

            // Quick pick amounts
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach([50, 100, 200, 300, 500], id: \.self) { amount in
                        Button {
                            extraAmount = Double(amount)
                            recalculate()
                        } label: {
                            Text("+$\(amount)")
                                .font(.system(size: 13, weight: extraAmount == Double(amount) ? .bold : .medium))
                                .foregroundStyle(extraAmount == Double(amount) ? .white : TCTheme.muted)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    extraAmount == Double(amount)
                                        ? AnyShapeStyle(TCTheme.accentGradient)
                                        : AnyShapeStyle(TCTheme.panelAlt.opacity(0.5))
                                )
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(
                                        extraAmount == Double(amount) ? .clear : TCTheme.line,
                                        lineWidth: 1
                                    )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Button {
                recalculate()
            } label: {
                Text("Recalculate")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(TCTheme.accentGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    private func resultsSection(base: CalculationResult, extra: CalculationResult) -> some View {
        VStack(spacing: 12) {
            // Months saved + Interest saved
            HStack(spacing: 12) {
                savingsCard(
                    icon: "calendar.badge.minus",
                    title: "Months Saved",
                    value: "\(extra.monthsSavedWithExtra)",
                    subtitle: "Payoff in \(extra.payoffMonthsWithExtra) mo instead of \(viewModel.vehicle.loanTermMonths)",
                    color: TCTheme.accent
                )
                savingsCard(
                    icon: "dollarsign.arrow.circlepath",
                    title: "Interest Saved",
                    value: TCTheme.formatCurrency(extra.interestSavedWithExtra),
                    subtitle: "Less interest paid over loan life",
                    color: TCTheme.good
                )
            }

            // Payoff date
            payoffDateCard(base: base, extra: extra)

            // New monthly payment
            VStack(alignment: .leading, spacing: 8) {
                Text("New Monthly Payment")
                    .font(.system(size: 12))
                    .foregroundStyle(TCTheme.muted)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(TCTheme.formatCurrency(base.monthlyPayment + extraAmount))
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundStyle(TCTheme.text)
                    Text("/mo")
                        .font(.system(size: 13))
                        .foregroundStyle(TCTheme.muted)
                }
                HStack(spacing: 4) {
                    Text("Base:")
                        .font(.system(size: 11))
                        .foregroundStyle(TCTheme.muted)
                    Text(TCTheme.formatCurrency(base.monthlyPayment))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(TCTheme.text)
                    Text("+")
                        .font(.system(size: 11))
                        .foregroundStyle(TCTheme.muted)
                    Text(TCTheme.formatCurrency(extraAmount))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(TCTheme.good)
                    Text("extra")
                        .font(.system(size: 11))
                        .foregroundStyle(TCTheme.muted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .tcCard()
        }
    }

    private func payoffDateCard(base: CalculationResult, extra: CalculationResult) -> some View {
        let originalDate = Calendar.current.date(byAdding: .month, value: viewModel.vehicle.loanTermMonths, to: Date()) ?? Date()
        let newDate = Calendar.current.date(byAdding: .month, value: extra.payoffMonthsWithExtra, to: Date()) ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"

        return HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Original Payoff")
                    .font(.system(size: 10))
                    .foregroundStyle(TCTheme.muted)
                Text(dateFormatter.string(from: originalDate))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(TCTheme.muted)
                    .strikethrough(color: TCTheme.bad.opacity(0.5))
            }

            Image(systemName: "arrow.right")
                .font(.system(size: 14))
                .foregroundStyle(TCTheme.good)

            VStack(alignment: .leading, spacing: 4) {
                Text("New Payoff")
                    .font(.system(size: 10))
                    .foregroundStyle(TCTheme.muted)
                Text(dateFormatter.string(from: newDate))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(TCTheme.good)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Earlier by")
                    .font(.system(size: 10))
                    .foregroundStyle(TCTheme.muted)
                let years = extra.monthsSavedWithExtra / 12
                let months = extra.monthsSavedWithExtra % 12
                Text(years > 0 ? "\(years)y \(months)m" : "\(months) months")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(TCTheme.good)
            }
        }
        .padding(14)
        .background(TCTheme.good.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(TCTheme.good.opacity(0.15), lineWidth: 1)
        )
    }

    private func savingsCard(icon: String, title: String, value: String, subtitle: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(color)
                Text(title)
                    .font(.system(size: 11))
                    .foregroundStyle(TCTheme.muted)
            }

            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(TCTheme.text)

            Text(subtitle)
                .font(.system(size: 10))
                .foregroundStyle(TCTheme.muted)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .tcTile()
    }

    private func recalculate() {
        var modified = viewModel.vehicle
        modified.extraMonthlyPayment = extraAmount
        extraResult = CostCalculator.calculate(for: modified)
    }
}

#Preview {
    ExtraPaymentView()
        .environment(VehicleViewModel())
}
