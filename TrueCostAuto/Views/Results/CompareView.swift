import SwiftUI

struct CompareView: View {
    @Environment(VehicleViewModel.self) private var viewModel
    @Environment(VehicleStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var selectedVehicles: Set<UUID> = []

    var body: some View {
        NavigationStack {
            ZStack {
                TCTheme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Current vehicle
                        currentVehicleCard

                        // Pick vehicles to compare
                        if store.savedVehicles.isEmpty {
                            emptyState
                        } else {
                            pickSection
                        }

                        // Comparison results
                        if !selectedVehicles.isEmpty {
                            comparisonResults
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Compare Vehicles")
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

    private var currentVehicleCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "car.fill")
                    .foregroundStyle(TCTheme.accent)
                Text("Current Vehicle")
                    .font(.system(size: 12))
                    .foregroundStyle(TCTheme.muted)
            }

            Text(viewModel.vehicle.name)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(TCTheme.text)

            if let result = viewModel.result {
                HStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("True Cost")
                            .font(.system(size: 10))
                            .foregroundStyle(TCTheme.muted)
                        Text(TCTheme.formatCurrency(result.trueMonthlyCost) + "/mo")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(TCTheme.accent)
                    }
                    VStack(alignment: .leading) {
                        Text("5-Year")
                            .font(.system(size: 10))
                            .foregroundStyle(TCTheme.muted)
                        Text(TCTheme.formatCurrency(result.fiveYearCost))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(TCTheme.text)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(TCTheme.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(TCTheme.accent.opacity(0.3), lineWidth: 1)
        )
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 32))
                .foregroundStyle(TCTheme.muted)
            Text("No saved vehicles to compare")
                .font(.system(size: 14))
                .foregroundStyle(TCTheme.muted)
            Text("Save a few vehicles first, then come back here to compare them side-by-side.")
                .font(.system(size: 12))
                .foregroundStyle(TCTheme.muted.opacity(0.7))
                .multilineTextAlignment(.center)

            Button {
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 12))
                    Text("Go Back")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(TCTheme.accent)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(TCTheme.accent.opacity(0.1))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(TCTheme.accent.opacity(0.2), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .tcCard()
    }

    private var pickSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Select vehicles to compare")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(TCTheme.muted)
                Spacer()
                Text("\(selectedVehicles.count)/3")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(selectedVehicles.count == 3 ? TCTheme.good : TCTheme.accent)
            }

            ForEach(store.savedVehicles.filter { $0.id != viewModel.vehicle.id }) { vehicle in
                let isSelected = selectedVehicles.contains(vehicle.id)
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    if isSelected {
                        selectedVehicles.remove(vehicle.id)
                    } else if selectedVehicles.count < 3 {
                        selectedVehicles.insert(vehicle.id)
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isSelected ? TCTheme.accent : TCTheme.muted)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(vehicle.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(TCTheme.text)
                            let r = CostCalculator.calculate(for: vehicle)
                            Text(TCTheme.formatCurrency(r.trueMonthlyCost) + "/mo true cost")
                                .font(.system(size: 12))
                                .foregroundStyle(TCTheme.muted)
                        }

                        Spacer()
                    }
                    .padding(12)
                    .background(isSelected ? TCTheme.accent.opacity(0.08) : TCTheme.panelAlt.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? TCTheme.accent.opacity(0.3) : TCTheme.line, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private var comparisonResults: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Comparison")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(TCTheme.text)

            let currentResult = viewModel.result ?? CostCalculator.calculate(for: viewModel.vehicle)

            ForEach(store.savedVehicles.filter { selectedVehicles.contains($0.id) }) { vehicle in
                let otherResult = CostCalculator.calculate(for: vehicle)
                let diff = currentResult.trueMonthlyCost - otherResult.trueMonthlyCost

                VStack(alignment: .leading, spacing: 8) {
                    Text(vehicle.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(TCTheme.text)

                    HStack(spacing: 16) {
                        diffItem("Monthly", diff, "/mo")
                        diffItem("5-Year", currentResult.fiveYearCost - otherResult.fiveYearCost, "")
                        diffItem("Interest", currentResult.totalInterest - otherResult.totalInterest, "")
                    }
                }
                .padding(14)
                .tcCard()
            }
        }
    }

    private func diffItem(_ label: String, _ diff: Double, _ suffix: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(TCTheme.muted)
            HStack(spacing: 2) {
                Image(systemName: diff > 0 ? "arrow.up" : diff < 0 ? "arrow.down" : "equal")
                    .font(.system(size: 9))
                Text(TCTheme.formatCurrency(abs(diff)) + suffix)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }
            .foregroundStyle(diff > 0 ? TCTheme.bad : diff < 0 ? TCTheme.good : TCTheme.muted)
        }
    }
}

#Preview {
    CompareView()
        .environment(VehicleViewModel())
        .environment(VehicleStore())
}
