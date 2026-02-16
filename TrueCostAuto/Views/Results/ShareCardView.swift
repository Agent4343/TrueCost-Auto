import SwiftUI

struct ShareCardView: View {
    let vehicle: Vehicle
    let result: CalculationResult
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                TCTheme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        Text("Share Summary")
                            .font(.system(size: 14))
                            .foregroundStyle(TCTheme.muted)

                        // The card
                        shareCard
                            .padding(.horizontal, 8)

                        // Share button
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            showShareSheet = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                                    .font(.system(size: 15, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(TCTheme.accentGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Share vehicle summary")

                        // Copy text
                        Button {
                            UIPasteboard.general.string = shareText
                            let feedback = UINotificationFeedbackGenerator()
                            feedback.notificationOccurred(.success)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "doc.on.doc")
                                Text("Copy as Text")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundStyle(TCTheme.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(TCTheme.panelAlt)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(TCTheme.accent.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Copy summary as text")
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .tint(TCTheme.accent)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ActivityView(items: [shareText])
            }
        }
        .preferredColorScheme(.dark)
    }

    private var shareCard: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                AppLogo(size: 28)
                Text("ShiftSync")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(TCTheme.text)
                Spacer()
            }

            // Vehicle name
            Text(vehicle.name)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(TCTheme.text)
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider().overlay(TCTheme.line)

            // Key metrics
            HStack(spacing: 0) {
                shareMetric("True Monthly", TCTheme.formatCurrency(result.trueMonthlyCost))
                shareMetric("5-Year Cost", TCTheme.formatCurrency(result.fiveYearCost))
                shareMetric("Smart Score", result.smartScore.rawValue)
            }

            Divider().overlay(TCTheme.line)

            // Breakdown
            VStack(spacing: 6) {
                shareRow("Loan Payment", TCTheme.formatCurrency(result.monthlyPayment) + "/mo")
                shareRow("Insurance", TCTheme.formatCurrency(vehicle.insurance) + "/mo")
                shareRow("Fuel", TCTheme.formatCurrency(vehicle.fuel) + "/mo")
                shareRow("Maintenance", TCTheme.formatCurrency(vehicle.maintenance) + "/mo")
                shareRow("Depreciation", TCTheme.formatCurrency(result.monthlyDepreciation) + "/mo")
                shareRow("Total Interest", TCTheme.formatCurrency(result.totalInterest))
            }
        }
        .padding(20)
        .background(TCTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(TCTheme.line, lineWidth: 1)
        )
    }

    private func shareMetric(_ label: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(TCTheme.muted)
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(TCTheme.accent)
        }
        .frame(maxWidth: .infinity)
    }

    private func shareRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(TCTheme.muted)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(TCTheme.text)
        }
    }

    private var shareText: String {
        """
        ShiftSync - \(vehicle.name)
        --------------------------------
        True Monthly Cost: \(TCTheme.formatCurrency(result.trueMonthlyCost))
        Daily Cost: ~\(TCTheme.formatCurrencyWithCents(result.dailyCost))
        Loan Payment: \(TCTheme.formatCurrency(result.monthlyPayment))/mo
        Running Costs: \(TCTheme.formatCurrency(vehicle.totalRunningCosts))/mo
        Depreciation: \(TCTheme.formatCurrency(result.monthlyDepreciation))/mo
        Total Interest: \(TCTheme.formatCurrency(result.totalInterest))
        Total Paid: \(TCTheme.formatCurrency(result.totalPaid))
        5-Year Cost: \(TCTheme.formatCurrency(result.fiveYearCost))
        Smart Score: \(result.smartScore.rawValue)\(result.incomePercentage.map { " (\(String(format: "%.1f", $0))% of income)" } ?? "")
        --------------------------------
        Calculated with ShiftSync
        """
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let vehicle = Vehicle.example
    let result = CostCalculator.calculate(for: vehicle)
    ShareCardView(vehicle: vehicle, result: result)
}
