import SwiftUI

struct RunningCostsSection: View {
    @Environment(VehicleViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel

        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "gauge.with.dots.needle.67percent")
                        .foregroundStyle(TCTheme.good)
                    Text("Monthly Running Costs")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(TCTheme.text)
                }
                Spacer()
                Text(TCTheme.formatCurrency(viewModel.vehicle.totalRunningCosts) + "/mo")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(TCTheme.good)
            }
            .padding(14)
            .background(TCTheme.panelAlt.opacity(0.55))

            Divider()
                .overlay(TCTheme.line)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                CurrencyField(
                    label: "Insurance",
                    unit: "$/mo",
                    value: $vm.vehicle.insurance
                )
                CurrencyField(
                    label: "Fuel / Charging",
                    unit: "$/mo",
                    value: $vm.vehicle.fuel
                )
                CurrencyField(
                    label: "Maintenance",
                    unit: "$/mo",
                    value: $vm.vehicle.maintenance
                )
                CurrencyField(
                    label: "Tires / Other",
                    unit: "$/mo",
                    value: $vm.vehicle.tiresAndOther
                )
            }
            .padding(14)

            // Running cost breakdown bar
            runningCostBar
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
        }
        .tcCard()
    }

    private var runningCostBar: some View {
        let total = viewModel.vehicle.totalRunningCosts
        guard total > 0 else { return AnyView(EmptyView()) }

        let items: [(String, Double, Color)] = [
            ("Insurance", viewModel.vehicle.insurance, TCTheme.accent),
            ("Fuel", viewModel.vehicle.fuel, TCTheme.good),
            ("Maint.", viewModel.vehicle.maintenance, TCTheme.warn),
            ("Other", viewModel.vehicle.tiresAndOther, TCTheme.accent2),
        ]

        return AnyView(
            VStack(spacing: 8) {
                GeometryReader { geo in
                    HStack(spacing: 2) {
                        ForEach(items, id: \.0) { item in
                            let pct = item.1 / total
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(item.2)
                                .frame(width: max(geo.size.width * pct - 2, 0))
                        }
                    }
                }
                .frame(height: 8)
                .clipShape(Capsule())

                HStack(spacing: 12) {
                    ForEach(items, id: \.0) { item in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(item.2)
                                .frame(width: 6, height: 6)
                            Text(item.0)
                                .font(.system(size: 10))
                                .foregroundStyle(TCTheme.muted)
                        }
                    }
                    Spacer()
                }
            }
        )
    }
}

#Preview {
    RunningCostsSection()
        .padding()
        .background(TCTheme.bg)
        .environment(VehicleViewModel())
        .preferredColorScheme(.dark)
}
