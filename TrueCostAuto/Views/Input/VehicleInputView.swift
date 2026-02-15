import SwiftUI

struct VehicleInputView: View {
    @Environment(VehicleViewModel.self) private var viewModel
    @Environment(VehicleStore.self) private var store

    @State private var vehicleName: String = ""
    @State private var showNameField = false

    var body: some View {
        @Bindable var vm = viewModel

        VStack(spacing: 16) {
            // Vehicle name (collapsible)
            nameSection

            PricingSection()
            LoanSection()
            RunningCostsSection()

            // Calculate button
            calculateButton
        }
    }

    private var nameSection: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    showNameField.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "car.fill")
                        .foregroundStyle(TCTheme.accent)
                    Text(viewModel.vehicle.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(TCTheme.text)
                    Spacer()
                    Image(systemName: showNameField ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundStyle(TCTheme.muted)
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if showNameField {
                @Bindable var vm = viewModel
                HStack(spacing: 10) {
                    TextField("e.g. 2024 Honda CR-V", text: $vm.vehicle.name)
                        .font(.system(size: 15))
                        .foregroundStyle(TCTheme.text)
                        .padding(10)
                        .background(TCTheme.panelAlt)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
        }
        .tcCard()
    }

    private var calculateButton: some View {
        Button {
            viewModel.recalculate()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                viewModel.showResults = true
            }
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                Text("Calculate True Cost")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(TCTheme.accentGradient)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: TCTheme.accent.opacity(0.25), radius: 15, y: 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ScrollView {
        VehicleInputView()
            .padding()
    }
    .background(TCTheme.bg)
    .environment(VehicleViewModel())
    .environment(VehicleStore())
    .preferredColorScheme(.dark)
}
