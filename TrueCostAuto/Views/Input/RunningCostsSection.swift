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
                if !viewModel.vehicle.useFuelEstimator {
                    CurrencyField(
                        label: "Fuel / Charging",
                        unit: "$/mo",
                        value: $vm.vehicle.fuel
                    )
                }
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
                CurrencyField(
                    label: "Warranty",
                    unit: "$/mo",
                    value: $vm.vehicle.warranty
                )
            }
            .padding(14)

            // Fuel Estimator
            fuelEstimatorSection

            // Running cost breakdown bar
            runningCostBar
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
        }
        .tcCard()
    }

    @ViewBuilder
    private var fuelEstimatorSection: some View {
        @Bindable var vm = viewModel

        VStack(spacing: 10) {
            Divider().overlay(TCTheme.line)

            HStack {
                Toggle(isOn: $vm.vehicle.useFuelEstimator) {
                    HStack(spacing: 6) {
                        Image(systemName: "fuelpump.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(TCTheme.good)
                        Text("Fuel Estimator")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(TCTheme.text)
                    }
                }
                .tint(TCTheme.accent)
            }
            .padding(.horizontal, 14)
            .padding(.top, 6)
            .onChange(of: viewModel.vehicle.useFuelEstimator) {
                if viewModel.vehicle.useFuelEstimator {
                    viewModel.updateFuelEstimate()
                }
            }

            if viewModel.vehicle.useFuelEstimator {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    CurrencyField(
                        label: "Annual Distance",
                        unit: viewModel.currency.distanceUnit,
                        value: $vm.vehicle.annualDistance
                    )
                    CurrencyField(
                        label: "Fuel Efficiency",
                        unit: viewModel.currency.fuelEfficiencyLabel,
                        value: $vm.vehicle.fuelEfficiency
                    )
                    CurrencyField(
                        label: "Fuel Price",
                        unit: viewModel.currency.fuelPriceLabel,
                        value: $vm.vehicle.fuelPricePerUnit
                    )
                }
                .padding(.horizontal, 14)
                .onChange(of: viewModel.vehicle.annualDistance) { viewModel.updateFuelEstimate() }
                .onChange(of: viewModel.vehicle.fuelEfficiency) { viewModel.updateFuelEstimate() }
                .onChange(of: viewModel.vehicle.fuelPricePerUnit) { viewModel.updateFuelEstimate() }

                // Computed fuel display
                HStack {
                    Text("Estimated Fuel Cost")
                        .font(.system(size: 12))
                        .foregroundStyle(TCTheme.muted)
                    Spacer()
                    Text(TCTheme.formatCurrency(viewModel.vehicle.fuel) + "/mo")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(TCTheme.good)
                }
                .padding(.horizontal, 14)
            }
        }
        .padding(.bottom, 10)
        .animation(.spring(response: 0.3), value: viewModel.vehicle.useFuelEstimator)
    }

    private var runningCostBar: some View {
        let total = viewModel.vehicle.totalRunningCosts
        guard total > 0 else { return AnyView(EmptyView()) }

        let items: [(String, Double, Color)] = [
            ("Insurance", viewModel.vehicle.insurance, TCTheme.accent),
            ("Fuel", viewModel.vehicle.fuel, TCTheme.good),
            ("Maint.", viewModel.vehicle.maintenance, TCTheme.warn),
            ("Other", viewModel.vehicle.tiresAndOther, TCTheme.accent2),
            ("Warranty", viewModel.vehicle.warranty, TCTheme.depreciation),
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
