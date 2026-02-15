import SwiftUI

struct PricingSection: View {
    @Environment(VehicleViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel

        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundStyle(TCTheme.accent)
                    Text("Pricing")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(TCTheme.text)
                }
                Spacer()
            }
            .padding(14)
            .background(TCTheme.panelAlt.opacity(0.55))

            Divider()
                .overlay(TCTheme.line)

            VStack(spacing: 0) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    CurrencyField(
                        label: "Vehicle Price",
                        unit: "$",
                        value: $vm.vehicle.vehiclePrice
                    )
                    CurrencyField(
                        label: "Fees & Extras",
                        unit: "$",
                        value: $vm.vehicle.feesAndExtras
                    )
                    CurrencyField(
                        label: "Down Payment",
                        unit: "$",
                        value: $vm.vehicle.downPayment
                    )
                    CurrencyField(
                        label: "Trade-In Value",
                        unit: "$",
                        value: $vm.vehicle.tradeInValue
                    )
                }
                .padding(14)

                // Amount financed preview
                HStack {
                    Text("Amount to Finance")
                        .font(.system(size: 12))
                        .foregroundStyle(TCTheme.muted)
                    Spacer()
                    Text(TCTheme.formatCurrency(viewModel.vehicle.amountFinanced))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(TCTheme.accent)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
        }
        .tcCard()
    }
}

#Preview {
    PricingSection()
        .padding()
        .background(TCTheme.bg)
        .environment(VehicleViewModel())
        .preferredColorScheme(.dark)
}
