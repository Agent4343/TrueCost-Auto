import SwiftUI

struct YearProjectionView: View {
    @Environment(VehicleViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                TCTheme.bg.ignoresSafeArea()

                ScrollView {
                    if let result = viewModel.result {
                        VStack(spacing: 16) {
                            summaryCard(result)
                            equityChart(result)
                            projectionTable(result)
                            depreciationNote
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Ownership Projection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .tint(TCTheme.accent)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Summary
    private func summaryCard(_ result: CalculationResult) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.xaxis")
                    .foregroundStyle(TCTheme.depreciation)
                Text("7-Year Ownership Overview")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(TCTheme.text)
                Spacer()
            }

            if let last = result.yearProjections.last {
                HStack(spacing: 0) {
                    metricColumn("Vehicle Value", TCTheme.formatCurrency(last.vehicleValue), TCTheme.depreciation)
                    metricColumn("Total Spent", TCTheme.formatCurrency(last.cumulativePaid), TCTheme.warn)
                    metricColumn("Equity", equityText(last.equity), last.equity >= 0 ? TCTheme.good : TCTheme.bad)
                }
            }
        }
        .padding(14)
        .background(TCTheme.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(TCTheme.accent.opacity(0.2), lineWidth: 1)
        )
    }

    private func metricColumn(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(TCTheme.muted)
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Equity Chart
    private func equityChart(_ result: CalculationResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Equity Over Time")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(TCTheme.text)

            GeometryReader { geo in
                let projections = result.yearProjections
                let maxVal = projections.map { max(abs($0.equity), $0.vehicleValue) }.max() ?? 1
                let barWidth = (geo.size.width - CGFloat(projections.count - 1) * 6) / CGFloat(projections.count)

                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(projections) { proj in
                        VStack(spacing: 4) {
                            // Value bar
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(TCTheme.depreciation.opacity(0.4))
                                .frame(width: barWidth, height: max(geo.size.height * 0.7 * (proj.vehicleValue / maxVal), 4))

                            // Equity indicator
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(proj.equity >= 0 ? TCTheme.good : TCTheme.bad)
                                .frame(width: barWidth, height: max(geo.size.height * 0.15 * (abs(proj.equity) / maxVal), 2))

                            Text("Y\(proj.year)")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(TCTheme.muted)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .frame(height: 140)

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2).fill(TCTheme.depreciation.opacity(0.4)).frame(width: 12, height: 8)
                    Text("Vehicle Value")
                        .font(.system(size: 10))
                        .foregroundStyle(TCTheme.muted)
                }
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2).fill(TCTheme.good).frame(width: 12, height: 8)
                    Text("Equity")
                        .font(.system(size: 10))
                        .foregroundStyle(TCTheme.muted)
                }
                Spacer()
            }
        }
        .padding(14)
        .tcCard()
    }

    // MARK: - Year-by-Year Table
    private func projectionTable(_ result: CalculationResult) -> some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "tablecells")
                        .foregroundStyle(TCTheme.accent)
                    Text("Year-by-Year Detail")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(TCTheme.text)
                }
                Spacer()
            }
            .padding(14)
            .background(TCTheme.panelAlt.opacity(0.55))

            Divider().overlay(TCTheme.line)

            // Header
            HStack {
                Text("Year")
                    .frame(width: 36, alignment: .leading)
                Text("Value")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Text("Owe")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Text("Spent")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Text("Equity")
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(TCTheme.muted)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(TCTheme.panelAlt.opacity(0.3))

            ForEach(result.yearProjections) { proj in
                HStack {
                    Text("\(proj.year)")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(TCTheme.muted)
                        .frame(width: 36, alignment: .leading)

                    Text(compactCurrency(proj.vehicleValue))
                        .foregroundStyle(TCTheme.depreciation)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    Text(compactCurrency(proj.loanBalance))
                        .foregroundStyle(proj.loanBalance > 0 ? TCTheme.warn : TCTheme.good)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    Text(compactCurrency(proj.cumulativePaid))
                        .foregroundStyle(TCTheme.text)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    Text(equityText(proj.equity))
                        .foregroundStyle(proj.equity >= 0 ? TCTheme.good : TCTheme.bad)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    proj.year % 2 == 0
                        ? TCTheme.panelAlt.opacity(0.3)
                        : Color.clear
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(TCTheme.line, lineWidth: 1)
        )
    }

    // MARK: - Note
    private var depreciationNote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle")
                .font(.system(size: 13))
                .foregroundStyle(TCTheme.muted)
                .padding(.top, 1)

            Text("Depreciation is estimated using a \(String(format: "%.0f", viewModel.vehicle.depreciationRate))% compound annual rate. Actual depreciation varies by make, model, mileage, and condition. Equity = Vehicle Value \u{2212} Loan Balance.")
                .font(.system(size: 11))
                .foregroundStyle(TCTheme.muted)
                .lineSpacing(2)
        }
        .padding(14)
        .background(TCTheme.panelAlt.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Helpers
    private func compactCurrency(_ value: Double) -> String {
        if value >= 1000 {
            return "$\(String(format: "%.1f", value / 1000))k"
        }
        return TCTheme.formatCurrency(value)
    }

    private func equityText(_ equity: Double) -> String {
        if equity < 0 {
            return "-" + TCTheme.formatCurrency(abs(equity))
        }
        return TCTheme.formatCurrency(equity)
    }
}

#Preview {
    YearProjectionView()
        .environment(VehicleViewModel())
        .environment(VehicleStore())
}
