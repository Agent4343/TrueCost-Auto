import SwiftUI

struct ResultsView: View {
    @Environment(VehicleViewModel.self) private var viewModel
    @Environment(VehicleStore.self) private var store
    @State private var showShareSheet = false
    @State private var showExtraPayment = false
    @State private var showCompare = false
    @State private var showAmortization = false
    @State private var animateIn = false

    var body: some View {
        if let result = viewModel.result {
            VStack(spacing: 16) {
                // Hero card
                TrueCostHeroCard(result: result)
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 20)

                // Breakdown tiles
                breakdownGrid(result)
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 30)

                // Cost pie chart approximation
                costBreakdownSection(result)
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 35)

                // Action rows
                actionsSection
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 40)

                // Save button
                saveButton
                    .opacity(animateIn ? 1 : 0)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    animateIn = true
                }
            }
            .onDisappear {
                animateIn = false
            }
            .sheet(isPresented: $showShareSheet) {
                ShareCardView(vehicle: viewModel.vehicle, result: result)
            }
            .sheet(isPresented: $showExtraPayment) {
                ExtraPaymentView()
            }
            .sheet(isPresented: $showCompare) {
                CompareView()
            }
            .sheet(isPresented: $showAmortization) {
                amortizationSheet(result)
            }
        }
    }

    private func breakdownGrid(_ result: CalculationResult) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            BreakdownTile(
                title: "Loan Payment",
                value: TCTheme.formatCurrency(result.monthlyPayment),
                subtitle: "\(TCTheme.formatCurrency(result.biWeeklyPayment)) bi-weekly",
                icon: "creditcard.fill",
                color: TCTheme.accent
            )
            BreakdownTile(
                title: "Total Interest",
                value: TCTheme.formatCurrency(result.totalInterest),
                subtitle: "over \(viewModel.vehicle.loanTermMonths) months",
                icon: "percent",
                color: TCTheme.warn
            )
            BreakdownTile(
                title: "Total Paid",
                value: TCTheme.formatCurrency(result.totalPaid),
                subtitle: "price + interest + tax",
                icon: "banknote.fill",
                color: TCTheme.accent2
            )
            BreakdownTile(
                title: "5-Year Cost",
                value: TCTheme.formatCurrency(result.fiveYearCost),
                subtitle: "incl. running costs",
                icon: "calendar.badge.clock",
                color: TCTheme.good
            )
        }
    }

    private func costBreakdownSection(_ result: CalculationResult) -> some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "chart.pie.fill")
                        .foregroundStyle(TCTheme.accent)
                    Text("Monthly Breakdown")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(TCTheme.text)
                }
                Spacer()
                Text(TCTheme.formatCurrency(result.trueMonthlyCost) + "/mo")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(TCTheme.accent)
            }
            .padding(14)
            .background(TCTheme.panelAlt.opacity(0.55))

            Divider().overlay(TCTheme.line)

            VStack(spacing: 10) {
                costRow("Loan Payment", result.monthlyPayment, result.trueMonthlyCost, TCTheme.accent)
                costRow("Insurance", viewModel.vehicle.insurance, result.trueMonthlyCost, TCTheme.accent2)
                costRow("Fuel / Charging", viewModel.vehicle.fuel, result.trueMonthlyCost, Color.orange)
                costRow("Maintenance", viewModel.vehicle.maintenance, result.trueMonthlyCost, TCTheme.good)
                costRow("Tires / Other", viewModel.vehicle.tiresAndOther, result.trueMonthlyCost, TCTheme.warn)
            }
            .padding(14)
        }
        .tcCard()
    }

    private func costRow(_ label: String, _ amount: Double, _ total: Double, _ color: Color) -> some View {
        let pct = total > 0 ? amount / total : 0
        return VStack(spacing: 6) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(label)
                    .font(.system(size: 12))
                    .foregroundStyle(TCTheme.muted)
                Spacer()
                Text(TCTheme.formatCurrency(amount))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(TCTheme.text)
                Text(String(format: "%.0f%%", pct * 100))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(TCTheme.muted)
                    .frame(width: 36, alignment: .trailing)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(color)
                        .frame(width: geo.size.width * pct)
                }
            }
            .frame(height: 4)
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 10) {
            actionRow(
                title: "Compare vs another car",
                subtitle: "Pick 2-3 vehicles side-by-side",
                icon: "arrow.left.arrow.right",
                isPro: false
            ) {
                showCompare = true
            }

            actionRow(
                title: "Share summary",
                subtitle: "Export a clean card to send a friend",
                icon: "square.and.arrow.up",
                isPro: false
            ) {
                showShareSheet = true
            }

            actionRow(
                title: "Extra payment scenario",
                subtitle: "See months saved + interest saved",
                icon: "arrow.up.right.circle",
                isPro: false
            ) {
                showExtraPayment = true
            }

            actionRow(
                title: "Amortization schedule",
                subtitle: "Month-by-month payment breakdown",
                icon: "tablecells",
                isPro: false
            ) {
                showAmortization = true
            }
        }
    }

    private func actionRow(title: String, subtitle: String, icon: String, isPro: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(TCTheme.accent)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(TCTheme.text)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(TCTheme.muted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(TCTheme.muted)
            }
            .padding(14)
            .background(TCTheme.panelAlt.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(TCTheme.line.opacity(0.6), style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
            )
        }
        .buttonStyle(.plain)
    }

    private var saveButton: some View {
        Button {
            store.save(viewModel.vehicle)
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 14))
                Text("Save Vehicle")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(TCTheme.panelAlt)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(TCTheme.accent.opacity(0.4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func amortizationSheet(_ result: CalculationResult) -> some View {
        NavigationStack {
            List {
                Section {
                    ForEach(result.amortizationSchedule) { entry in
                        HStack {
                            Text("Mo \(entry.month)")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundStyle(TCTheme.muted)
                                .frame(width: 50, alignment: .leading)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Principal: \(TCTheme.formatCurrency(entry.principal))")
                                    .font(.system(size: 12))
                                    .foregroundStyle(TCTheme.good)
                                Text("Interest: \(TCTheme.formatCurrency(entry.interest))")
                                    .font(.system(size: 12))
                                    .foregroundStyle(TCTheme.warn)
                            }

                            Spacer()

                            Text(TCTheme.formatCurrency(entry.remainingBalance))
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(TCTheme.text)
                        }
                        .listRowBackground(TCTheme.panelAlt)
                    }
                } header: {
                    Text("Month-by-month breakdown")
                }
            }
            .scrollContentBackground(.hidden)
            .background(TCTheme.bg)
            .navigationTitle("Amortization")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showAmortization = false }
                }
            }
        }
        .presentationDetents([.large])
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ScrollView {
        ResultsView()
            .padding()
    }
    .background(TCTheme.bg)
    .environment(VehicleViewModel())
    .environment(VehicleStore())
    .preferredColorScheme(.dark)
}
