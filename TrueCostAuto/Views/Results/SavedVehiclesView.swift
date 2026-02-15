import SwiftUI

struct SavedVehiclesView: View {
    @Environment(VehicleStore.self) private var store
    @Environment(VehicleViewModel.self) private var viewModel

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            if store.savedVehicles.isEmpty {
                emptyState
            } else {
                vehicleList
            }
        }
        .navigationTitle("Saved Vehicles")
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 44))
                .foregroundStyle(TCTheme.muted.opacity(0.5))

            Text("No Saved Vehicles")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(TCTheme.text)

            Text("Calculate the true cost of a vehicle, then save it here to compare later.")
                .font(.system(size: 14))
                .foregroundStyle(TCTheme.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private var vehicleList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(store.savedVehicles) { vehicle in
                    savedVehicleCard(vehicle)
                }
            }
            .padding(16)
        }
    }

    private func savedVehicleCard(_ vehicle: Vehicle) -> some View {
        let result = CostCalculator.calculate(for: vehicle)

        return Button {
            viewModel.loadVehicle(vehicle)
        } label: {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vehicle.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(TCTheme.text)
                        Text("Saved \(vehicle.createdAt.formatted(.relative(presentation: .named)))")
                            .font(.system(size: 11))
                            .foregroundStyle(TCTheme.muted)
                    }
                    Spacer()

                    // Delete
                    Button {
                        withAnimation {
                            store.delete(vehicle)
                        }
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 13))
                            .foregroundStyle(TCTheme.bad.opacity(0.7))
                            .padding(8)
                    }
                }

                Divider().overlay(TCTheme.line)

                HStack(spacing: 0) {
                    miniMetric("True Cost", TCTheme.formatCurrency(result.trueMonthlyCost) + "/mo", TCTheme.accent)
                    miniMetric("Payment", TCTheme.formatCurrency(result.monthlyPayment) + "/mo", TCTheme.text)
                    miniMetric("5-Year", TCTheme.formatCurrency(result.fiveYearCost), TCTheme.text)
                    miniMetric("Score", result.smartScore.rawValue, TCTheme.scoreColor(for: result.smartScore))
                }
            }
            .padding(14)
            .tcCard()
        }
        .buttonStyle(.plain)
    }

    private func miniMetric(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(TCTheme.muted)
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private var backgroundGradient: some View {
        ZStack {
            TCTheme.bg
            RadialGradient(
                colors: [TCTheme.accent.opacity(0.08), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 500
            )
        }
    }
}

#Preview {
    NavigationStack {
        SavedVehiclesView()
    }
    .environment(VehicleStore())
    .environment(VehicleViewModel())
    .preferredColorScheme(.dark)
}
