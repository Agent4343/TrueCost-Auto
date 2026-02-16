import SwiftUI

struct ResultsView: View {
    @Environment(VehicleViewModel.self) private var viewModel
    @Environment(VehicleStore.self) private var store
    @State private var showShareSheet = false
    @State private var showExtraPayment = false
    @State private var showCompare = false
    @State private var showAmortization = false
    @State private var showProjection = false
    @State private var animateIn = false
    @State private var tileAnimations = [false, false, false, false]

    var body: some View {
        if let result = viewModel.result {
            VStack(spacing: 16) {
                // Hero card
                TrueCostHeroCard(result: result)
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 20)

                // Affordability insight
                affordabilityInsight(result)
                    .opacity(tileAnimations[0] ? 1 : 0)
                    .offset(y: tileAnimations[0] ? 0 : 15)

                // Breakdown tiles with stagger
                breakdownGrid(result)

                // Cost breakdown
                costBreakdownSection(result)
                    .opacity(tileAnimations[2] ? 1 : 0)
                    .offset(y: tileAnimations[2] ? 0 : 20)

                // Action rows
                actionsSection
                    .opacity(tileAnimations[3] ? 1 : 0)
                    .offset(y: tileAnimations[3] ? 0 : 20)

                // Save button
                saveButton
                    .opacity(tileAnimations[3] ? 1 : 0)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    animateIn = true
                }
                // Stagger tile animations
                for i in 0..<4 {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2 + Double(i) * 0.08)) {
                        tileAnimations[i] = true
                    }
                }
            }
            .onDisappear {
                animateIn = false
                tileAnimations = [false, false, false, false]
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
            .sheet(isPresented: $showProjection) {
                YearProjectionView()
            }
        }
    }

    // MARK: - Affordability Insight Card
    private func affordabilityInsight(_ result: CalculationResult) -> some View {
        let score = result.smartScore
        let icon: String
        let message: String
        let tipColor: Color

        switch score {
        case .excellent:
            icon = "hand.thumbsup.fill"
            message = "Great choice! This vehicle is well within your budget. You'll have room for savings and unexpected expenses."
            tipColor = TCTheme.good
        case .reasonable:
            icon = "checkmark.shield.fill"
            message = "This is a manageable purchase. Consider a shorter loan term to save on interest."
            tipColor = TCTheme.good
        case .stretch:
            icon = "exclamationmark.triangle.fill"
            message = "This vehicle will stretch your budget. Adding \(TCTheme.formatCurrency(200)) extra per month could save you \(TCTheme.formatCurrency(result.interestSavedWithExtra)) in interest."
            tipColor = TCTheme.warn
        case .risky:
            icon = "exclamationmark.octagon.fill"
            message = "This purchase could cause financial stress. Consider increasing your down payment or choosing a less expensive vehicle."
            tipColor = TCTheme.bad
        case .overextended:
            icon = "xmark.octagon.fill"
            message = "This vehicle is likely beyond your current budget. The monthly cost is over 30% of your income."
            tipColor = TCTheme.bad
        }

        return HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(tipColor)
                .frame(width: 24)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Affordability Insight")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(tipColor)
                Text(message)
                    .font(.system(size: 12))
                    .foregroundStyle(TCTheme.muted)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(tipColor.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(tipColor.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Breakdown Tiles
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
            .opacity(tileAnimations[1] ? 1 : 0)
            .offset(y: tileAnimations[1] ? 0 : 20)

            BreakdownTile(
                title: "Total Interest",
                value: TCTheme.formatCurrency(result.totalInterest),
                subtitle: "over \(viewModel.vehicle.loanTermMonths) months",
                icon: "percent",
                color: TCTheme.warn
            )
            .opacity(tileAnimations[1] ? 1 : 0)
            .offset(y: tileAnimations[1] ? 0 : 20)

            BreakdownTile(
                title: "Depreciation",
                value: TCTheme.formatCurrency(result.monthlyDepreciation) + "/mo",
                subtitle: "\(TCTheme.formatCurrency(result.fiveYearDepreciation)) over 5 yr",
                icon: "chart.line.downtrend.xyaxis",
                color: TCTheme.depreciation
            )
            .opacity(tileAnimations[1] ? 1 : 0)
            .offset(y: tileAnimations[1] ? 0 : 25)

            BreakdownTile(
                title: "5-Year Cost",
                value: TCTheme.formatCurrency(result.fiveYearCost),
                subtitle: "total ownership cost",
                icon: "calendar.badge.clock",
                color: TCTheme.good
            )
            .opacity(tileAnimations[1] ? 1 : 0)
            .offset(y: tileAnimations[1] ? 0 : 25)
        }
    }

    // MARK: - Monthly Breakdown
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
                costRow("Insurance", viewModel.vehicle.insurance, result.trueMonthlyCost, TCTheme.accent)
                costRow("Fuel / Charging", viewModel.vehicle.fuel, result.trueMonthlyCost, TCTheme.good)
                costRow("Maintenance", viewModel.vehicle.maintenance, result.trueMonthlyCost, TCTheme.warn)
                costRow("Tires / Other", viewModel.vehicle.tiresAndOther, result.trueMonthlyCost, TCTheme.accent2)
                costRow("Depreciation", result.monthlyDepreciation, result.trueMonthlyCost, TCTheme.depreciation)
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

    // MARK: - Action Rows
    private var actionsSection: some View {
        VStack(spacing: 10) {
            actionRow(
                title: "Compare vs another car",
                subtitle: "Pick 2-3 vehicles side-by-side",
                icon: "arrow.left.arrow.right",
                color: TCTheme.accent
            ) {
                showCompare = true
            }

            actionRow(
                title: "Ownership projection",
                subtitle: "Year-by-year value & equity",
                icon: "chart.bar.xaxis",
                color: TCTheme.depreciation
            ) {
                showProjection = true
            }

            actionRow(
                title: "Share summary",
                subtitle: "Export a clean card to send a friend",
                icon: "square.and.arrow.up",
                color: TCTheme.good
            ) {
                showShareSheet = true
            }

            actionRow(
                title: "Extra payment scenario",
                subtitle: "See months saved + interest saved",
                icon: "arrow.up.right.circle",
                color: TCTheme.warn
            ) {
                showExtraPayment = true
            }

            actionRow(
                title: "Amortization schedule",
                subtitle: "Month-by-month payment breakdown",
                icon: "tablecells",
                color: TCTheme.accent2
            ) {
                showAmortization = true
            }
        }
    }

    private func actionRow(title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

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
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
    }

    // MARK: - Save Button
    private var saveButton: some View {
        Button {
            viewModel.saveVehicle(to: store)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 14))
                Text("Save Vehicle")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(TCTheme.accentGradient)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: TCTheme.accent.opacity(0.2), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Save vehicle")
        .accessibilityHint("Saves this vehicle to your collection for later comparison")
    }

    // MARK: - Amortization Sheet
    private func amortizationSheet(_ result: CalculationResult) -> some View {
        NavigationStack {
            ZStack {
                TCTheme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Summary header
                        amortizationSummary(result)

                        // Table
                        LazyVStack(spacing: 0) {
                            // Column headers
                            HStack {
                                Text("Month")
                                    .frame(width: 44, alignment: .leading)
                                Text("Principal")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                Text("Interest")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                Text("Balance")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(TCTheme.muted)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(TCTheme.panelAlt.opacity(0.55))

                            ForEach(result.amortizationSchedule) { entry in
                                HStack {
                                    Text("\(entry.month)")
                                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                                        .foregroundStyle(TCTheme.muted)
                                        .frame(width: 44, alignment: .leading)

                                    Text(TCTheme.formatCurrency(entry.principal))
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundStyle(TCTheme.good)
                                        .frame(maxWidth: .infinity, alignment: .trailing)

                                    Text(TCTheme.formatCurrency(entry.interest))
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundStyle(TCTheme.warn)
                                        .frame(maxWidth: .infinity, alignment: .trailing)

                                    Text(TCTheme.formatCurrency(entry.remainingBalance))
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(TCTheme.text)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    entry.month % 2 == 0
                                        ? TCTheme.panelAlt.opacity(0.3)
                                        : Color.clear
                                )
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(TCTheme.line, lineWidth: 1)
                        )
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Amortization")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showAmortization = false }
                        .tint(TCTheme.accent)
                }
            }
        }
        .presentationDetents([.large])
        .preferredColorScheme(.dark)
    }

    private func amortizationSummary(_ result: CalculationResult) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("Principal")
                        .font(.system(size: 10))
                        .foregroundStyle(TCTheme.muted)
                    Text(TCTheme.formatCurrency(result.totalPaid - result.totalInterest))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(TCTheme.good)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    Text("Interest")
                        .font(.system(size: 10))
                        .foregroundStyle(TCTheme.muted)
                    Text(TCTheme.formatCurrency(result.totalInterest))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(TCTheme.warn)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    Text("Total")
                        .font(.system(size: 10))
                        .foregroundStyle(TCTheme.muted)
                    Text(TCTheme.formatCurrency(result.totalPaid))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(TCTheme.text)
                }
                .frame(maxWidth: .infinity)
            }

            // Interest ratio bar
            GeometryReader { geo in
                let principalPct = result.totalPaid > 0
                    ? (result.totalPaid - result.totalInterest) / result.totalPaid
                    : 1.0
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(TCTheme.good)
                        .frame(width: geo.size.width * principalPct)
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(TCTheme.warn)
                }
            }
            .frame(height: 8)
            .clipShape(Capsule())

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle().fill(TCTheme.good).frame(width: 6, height: 6)
                    Text("Principal")
                        .font(.system(size: 10))
                        .foregroundStyle(TCTheme.muted)
                }
                HStack(spacing: 4) {
                    Circle().fill(TCTheme.warn).frame(width: 6, height: 6)
                    Text("Interest")
                        .font(.system(size: 10))
                        .foregroundStyle(TCTheme.muted)
                }
                Spacer()
            }
        }
        .padding(14)
        .tcCard()
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
