import SwiftUI

// MARK: - Wizard Entry Point

struct DealCheckWizardView: View {
    @Environment(VehicleViewModel.self) private var vm
    @State private var step: WizardStep = .budget

    enum WizardStep: Int, CaseIterable {
        case budget = 0
        case deal = 1
        case usage = 2
        case review = 3

        var title: String {
            switch self {
            case .budget: return "Your Budget"
            case .deal: return "The Deal"
            case .usage: return "Your Usage"
            case .review: return "Review"
            }
        }

        var subtitle: String {
            switch self {
            case .budget: return "What can you comfortably afford each month?"
            case .deal: return "Enter the vehicle and financing details."
            case .usage: return "How much will you spend operating this vehicle?"
            case .review: return "Confirm before we run your DealFit analysis."
            }
        }

        var systemIcon: String {
            switch self {
            case .budget: return "dollarsign.circle.fill"
            case .deal: return "car.fill"
            case .usage: return "fuelpump.fill"
            case .review: return "checkmark.shield.fill"
            }
        }
    }

    var body: some View {
        ZStack {
            TCTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                wizardHeader

                // Progress bar
                WizardProgressBar(currentStep: step.rawValue, totalSteps: WizardStep.allCases.count)
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 20)

                // Step title
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        Image(systemName: step.systemIcon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(TCTheme.accent)
                        Text(step.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(TCTheme.text)
                    }
                    Text(step.subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(TCTheme.muted)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                // Step content
                ScrollView {
                    stepContent
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                }

                // Navigation buttons
                navigationButtons
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Header

    private var wizardHeader: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    vm.showWizard = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(TCTheme.muted)
                    .frame(width: 32, height: 32)
                    .background(TCTheme.panelAlt)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close wizard")

            Text("Deal Check")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(TCTheme.text)

            Spacer()

            Text("\(step.rawValue + 1) of \(WizardStep.allCases.count)")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(TCTheme.muted)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .budget:
            WizardBudgetStep()
        case .deal:
            WizardDealStep()
        case .usage:
            WizardUsageStep()
        case .review:
            WizardReviewStep()
        }
    }

    // MARK: - Navigation

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if step.rawValue > 0 {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        step = WizardStep(rawValue: step.rawValue - 1) ?? .budget
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(TCTheme.muted)
                    .frame(width: 90)
                    .padding(.vertical, 16)
                    .background(TCTheme.panelAlt)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(TCTheme.line, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Go back")
            }

            Button {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                if step == .review {
                    vm.recalculate()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        vm.showResults = true
                        vm.showWizard = false
                    }
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        step = WizardStep(rawValue: step.rawValue + 1) ?? .review
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(step == .review ? "Get My Verdict" : "Continue")
                        .font(.system(size: 16, weight: .bold))
                    Image(systemName: step == .review ? "arrow.right.circle.fill" : "chevron.right")
                        .font(.system(size: step == .review ? 16 : 13, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(TCTheme.accentGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: TCTheme.accent.opacity(0.3), radius: 12, y: 6)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(step == .review ? "Get my verdict" : "Continue to next step")
        }
    }
}

// MARK: - Progress Bar

struct WizardProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { i in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(i <= currentStep ? TCTheme.accent : TCTheme.line)
                    .frame(maxWidth: .infinity)
                    .frame(height: 4)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
            }
        }
    }
}

// MARK: - Step: Budget

struct WizardBudgetStep: View {
    @Environment(VehicleViewModel.self) private var vm

    var body: some View {
        @Bindable var vm = vm
        VStack(spacing: 16) {
            WizardFieldCard(title: "Monthly Budget", icon: "dollarsign.circle.fill") {
                CurrencyField(
                    label: "Monthly Budget",
                    unit: vm.currencySymbol + "/mo",
                    value: $vm.vehicle.monthlyBudget,
                    placeholder: "e.g. 800"
                )
            }

            WizardFieldCard(
                title: "Monthly Take-Home Pay",
                icon: "person.fill",
                subtitle: "Optional — powers DealFit Index"
            ) {
                CurrencyField(
                    label: "Take-Home Pay",
                    unit: vm.currencySymbol + "/mo",
                    value: $vm.vehicle.monthlyIncome,
                    placeholder: "e.g. 5,000"
                )
            }

            if vm.vehicle.monthlyBudget > 0 {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(TCTheme.warn)
                    Text("A healthy guideline: keep total vehicle costs under 15–20% of take-home pay.")
                        .font(.system(size: 12))
                        .foregroundStyle(TCTheme.muted)
                        .lineSpacing(2)
                }
                .padding(12)
                .background(TCTheme.warn.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(TCTheme.warn.opacity(0.2), lineWidth: 1))
            }
        }
    }
}

// MARK: - Step: Deal

struct WizardDealStep: View {
    @Environment(VehicleViewModel.self) private var vm

    var body: some View {
        @Bindable var vm = vm
        VStack(spacing: 16) {
            WizardFieldCard(title: "Vehicle Name", icon: "car.fill", subtitle: "Optional — for your records") {
                TextField("e.g. 2025 Toyota RAV4 XLE", text: $vm.vehicle.name)
                    .font(.system(size: 15))
                    .foregroundStyle(TCTheme.text)
                    .padding(12)
                    .background(TCTheme.panelAlt.opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(TCTheme.line, lineWidth: 1))
            }

            WizardFieldCard(title: "Vehicle Price", icon: "tag.fill") {
                CurrencyField(label: "Vehicle Price", unit: vm.currencySymbol, value: $vm.vehicle.vehiclePrice)
            }

            HStack(spacing: 12) {
                WizardFieldCard(title: "Down Payment", icon: "arrow.down.circle.fill") {
                    CurrencyField(label: "Down Payment", unit: vm.currencySymbol, value: $vm.vehicle.downPayment)
                }
                WizardFieldCard(title: "Trade-In", icon: "arrow.triangle.2.circlepath") {
                    CurrencyField(label: "Trade-In", unit: vm.currencySymbol, value: $vm.vehicle.tradeInValue)
                }
            }

            WizardFieldCard(title: "Fees & Extras", icon: "doc.text.fill", subtitle: "Dealer fees, admin, etc.") {
                CurrencyField(label: "Fees & Extras", unit: vm.currencySymbol, value: $vm.vehicle.feesAndExtras)
            }

            WizardFieldCard(title: "Loan Terms", icon: "calendar.badge.clock") {
                VStack(spacing: 14) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("APR")
                                .font(.system(size: 12))
                                .foregroundStyle(TCTheme.muted)
                            PercentField(label: "APR", value: $vm.vehicle.interestRate)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sales Tax")
                                .font(.system(size: 12))
                                .foregroundStyle(TCTheme.muted)
                            PercentField(label: "Sales Tax", value: $vm.vehicle.salesTaxRate)
                        }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Term")
                            .font(.system(size: 12))
                            .foregroundStyle(TCTheme.muted)
                        TermPicker(selectedTerm: $vm.vehicle.loanTermMonths, terms: Vehicle.availableTerms)
                    }
                }
            }

            // Financed amount preview
            let financed = vm.vehicle.amountFinanced
            if financed > 0 {
                HStack {
                    Text("Amount to Finance")
                        .font(.system(size: 13))
                        .foregroundStyle(TCTheme.muted)
                    Spacer()
                    Text(TCTheme.formatCurrency(financed, symbol: vm.currencySymbol))
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundStyle(TCTheme.accent)
                }
                .padding(12)
                .background(TCTheme.accent.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}

// MARK: - Step: Usage

struct WizardUsageStep: View {
    @Environment(VehicleViewModel.self) private var vm

    var body: some View {
        @Bindable var vm = vm
        VStack(spacing: 16) {
            WizardFieldCard(title: "Monthly Insurance", icon: "shield.fill") {
                CurrencyField(label: "Insurance", unit: vm.currencySymbol + "/mo", value: $vm.vehicle.insurance)
            }

            WizardFieldCard(title: "Fuel / Charging", icon: "fuelpump.fill") {
                VStack(spacing: 12) {
                    Toggle(isOn: $vm.vehicle.useFuelEstimator) {
                        Text("Use Fuel Estimator")
                            .font(.system(size: 14))
                            .foregroundStyle(TCTheme.text)
                    }
                    .tint(TCTheme.accent)
                    .onChange(of: vm.vehicle.useFuelEstimator) { _, _ in
                        vm.updateFuelEstimate()
                    }

                    if vm.vehicle.useFuelEstimator {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Distance/yr")
                                    .font(.system(size: 11))
                                    .foregroundStyle(TCTheme.muted)
                                CurrencyField(label: "Distance/yr", unit: vm.currency.distanceUnit, value: $vm.vehicle.annualDistance)
                                    .onChange(of: vm.vehicle.annualDistance) { _, _ in vm.updateFuelEstimate() }
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Efficiency")
                                    .font(.system(size: 11))
                                    .foregroundStyle(TCTheme.muted)
                                CurrencyField(label: "Efficiency", unit: vm.currency.fuelEfficiencyLabel, value: $vm.vehicle.fuelEfficiency)
                                    .onChange(of: vm.vehicle.fuelEfficiency) { _, _ in vm.updateFuelEstimate() }
                            }
                        }
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Price/unit")
                                    .font(.system(size: 11))
                                    .foregroundStyle(TCTheme.muted)
                                CurrencyField(label: "Price/unit", unit: vm.currency.fuelPriceLabel, value: $vm.vehicle.fuelPricePerUnit)
                                    .onChange(of: vm.vehicle.fuelPricePerUnit) { _, _ in vm.updateFuelEstimate() }
                            }
                            Spacer()
                        }
                    } else {
                        CurrencyField(label: "Fuel/Charging", unit: vm.currencySymbol + "/mo", value: $vm.vehicle.fuel)
                    }
                }
            }

            HStack(spacing: 12) {
                WizardFieldCard(title: "Maintenance", icon: "wrench.and.screwdriver.fill") {
                    CurrencyField(label: "Maintenance", unit: vm.currencySymbol + "/mo", value: $vm.vehicle.maintenance)
                }
                WizardFieldCard(title: "Tires & Other", icon: "circle.inset.filled") {
                    CurrencyField(label: "Tires & Other", unit: vm.currencySymbol + "/mo", value: $vm.vehicle.tiresAndOther)
                }
            }

            WizardFieldCard(
                title: "Annual Depreciation",
                icon: "arrow.down.right.circle.fill",
                subtitle: "Typical range 10–20%/yr"
            ) {
                VStack(spacing: 8) {
                    HStack {
                        Text(TCTheme.formatPercent(vm.vehicle.depreciationRate))
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundStyle(TCTheme.depreciation)
                        Spacer()
                        Text("−\(TCTheme.formatCurrency(vm.vehicle.vehiclePrice * vm.vehicle.depreciationRate / 100, symbol: vm.currencySymbol))/yr")
                            .font(.system(size: 12))
                            .foregroundStyle(TCTheme.muted)
                    }
                    Slider(value: $vm.vehicle.depreciationRate, in: 5...30, step: 0.5)
                        .tint(TCTheme.depreciation)
                        .accessibilityLabel("Depreciation rate \(TCTheme.formatPercent(vm.vehicle.depreciationRate))")
                }
            }
        }
    }
}

// MARK: - Step: Review

struct WizardReviewStep: View {
    @Environment(VehicleViewModel.self) private var vm

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "car.fill")
                        .foregroundStyle(TCTheme.accent)
                    Text(vm.vehicle.name.isEmpty ? "New Vehicle" : vm.vehicle.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(TCTheme.text)
                    Spacer()
                }

                Divider().background(TCTheme.line)

                ReviewRow(label: "Vehicle Price", value: TCTheme.formatCurrency(vm.vehicle.vehiclePrice, symbol: vm.currencySymbol))
                ReviewRow(label: "Down + Trade-In", value: TCTheme.formatCurrency(vm.vehicle.downPayment + vm.vehicle.tradeInValue, symbol: vm.currencySymbol))
                ReviewRow(label: "Amount to Finance", value: TCTheme.formatCurrency(vm.vehicle.amountFinanced, symbol: vm.currencySymbol), emphasized: true)

                Divider().background(TCTheme.line)

                ReviewRow(label: "APR", value: TCTheme.formatPercent(vm.vehicle.interestRate))
                ReviewRow(label: "Term", value: "\(vm.vehicle.loanTermMonths) months")
                ReviewRow(label: "Running Costs", value: "\(TCTheme.formatCurrency(vm.vehicle.totalRunningCosts, symbol: vm.currencySymbol))/mo")
                ReviewRow(label: "Depreciation", value: "\(TCTheme.formatPercent(vm.vehicle.depreciationRate))/yr")

                if vm.vehicle.monthlyBudget > 0 {
                    Divider().background(TCTheme.line)
                    ReviewRow(label: "Your Monthly Budget", value: "\(TCTheme.formatCurrency(vm.vehicle.monthlyBudget, symbol: vm.currencySymbol))/mo", emphasized: true)
                }
            }
            .padding(16)
            .tcCard()

            Text("Tap \"Get My Verdict\" to compute your DealFit Index, true monthly cost breakdown, and personalized recommendations.")
                .font(.system(size: 13))
                .foregroundStyle(TCTheme.muted)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 8)
        }
    }
}

// MARK: - Wizard Field Card

struct WizardFieldCard<Content: View>: View {
    let title: String
    let icon: String
    var subtitle: String? = nil
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(TCTheme.accent)
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(TCTheme.muted)
                if let sub = subtitle {
                    Text("· \(sub)")
                        .font(.system(size: 11))
                        .foregroundStyle(TCTheme.muted.opacity(0.6))
                }
            }
            content
        }
        .padding(14)
        .background(TCTheme.panel.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(TCTheme.line, lineWidth: 1))
    }
}

// MARK: - Review Row

struct ReviewRow: View {
    let label: String
    let value: String
    var emphasized: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: emphasized ? 14 : 13, weight: emphasized ? .semibold : .regular))
                .foregroundStyle(emphasized ? TCTheme.text : TCTheme.muted)
            Spacer()
            Text(value)
                .font(.system(size: emphasized ? 15 : 13, weight: emphasized ? .bold : .semibold, design: .monospaced))
                .foregroundStyle(emphasized ? TCTheme.accent : TCTheme.text)
        }
    }
}

#Preview {
    DealCheckWizardView()
        .environment(VehicleViewModel())
        .environment(VehicleStore())
}
