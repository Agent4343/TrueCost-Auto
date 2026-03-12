import SwiftUI

/// A custom SwiftUI stacked-bar chart showing the composition of true monthly cost.
/// No external dependencies — built entirely with SwiftUI primitives.
struct CostStackChartView: View {

    struct Segment: Identifiable {
        var id: String { label }
        let label: String
        let value: Double
        let color: Color
    }

    let segments: [Segment]

    private var total: Double { segments.reduce(0) { $0 + $1.value } }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Stacked bar
            GeometryReader { geo in
                HStack(spacing: 2) {
                    ForEach(segments) { seg in
                        if seg.value > 0 {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(seg.color)
                                .frame(width: max(barWidth(for: seg, totalWidth: geo.size.width), 6))
                                .accessibilityLabel("\(seg.label): \(Int(seg.value / total * 100))%")
                        }
                    }
                }
            }
            .frame(height: 28)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            // Legend
            FlowLayout(segments: segments, total: total)
        }
    }

    private func barWidth(for seg: Segment, totalWidth: CGFloat) -> CGFloat {
        guard total > 0 else { return 0 }
        let count = segments.filter { $0.value > 0 }.count
        let gaps = CGFloat(max(count - 1, 0)) * 2
        let available = totalWidth - gaps
        return available * CGFloat(seg.value / total)
    }
}

// MARK: - Flow Legend

private struct FlowLayout: View {
    let segments: [CostStackChartView.Segment]
    let total: Double

    var body: some View {
        let cols = 2
        let items = segments.filter { $0.value > 0 }
        let rows = Int(ceil(Double(items.count) / Double(cols)))

        VStack(alignment: .leading, spacing: 6) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(0..<cols, id: \.self) { col in
                        let idx = row * cols + col
                        if idx < items.count {
                            legendItem(items[idx])
                        } else {
                            Spacer()
                        }
                    }
                }
            }
        }
    }

    private func legendItem(_ seg: CostStackChartView.Segment) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(seg.color)
                .frame(width: 8, height: 8)
            Text(seg.label)
                .font(.system(size: 11))
                .foregroundStyle(TCTheme.muted)
            Spacer(minLength: 0)
            Text("\(Int(seg.value / max(total, 1) * 100))%")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(TCTheme.text)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Convenience factory

extension CostStackChartView {
    static func forResult(_ result: CalculationResult, vehicle: Vehicle, symbol: String) -> CostStackChartView {
        CostStackChartView(segments: [
            Segment(label: "Loan", value: result.monthlyPayment, color: TCTheme.accent),
            Segment(label: "Depreciation", value: result.monthlyDepreciation, color: TCTheme.depreciation),
            Segment(label: "Insurance", value: vehicle.insurance, color: TCTheme.accent2),
            Segment(label: "Fuel", value: vehicle.fuel, color: TCTheme.good),
            Segment(label: "Maintenance", value: vehicle.maintenance + vehicle.tiresAndOther + vehicle.warranty, color: TCTheme.muted),
        ])
    }
}

#Preview {
    VStack(spacing: 24) {
        CostStackChartView(segments: [
            .init(label: "Loan", value: 620, color: TCTheme.accent),
            .init(label: "Depreciation", value: 180, color: TCTheme.depreciation),
            .init(label: "Insurance", value: 190, color: TCTheme.accent2),
            .init(label: "Fuel", value: 240, color: TCTheme.good),
            .init(label: "Maintenance", value: 90, color: TCTheme.muted),
        ])
        .padding(16)
        .background(TCTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(24)
    }
    .background(TCTheme.bg)
    .preferredColorScheme(.dark)
}
