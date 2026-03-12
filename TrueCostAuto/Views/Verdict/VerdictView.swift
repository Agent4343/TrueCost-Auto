import SwiftUI

/// Primary results screen — replaces the old ResultsView as the first thing shown after the wizard.
struct VerdictView: View {
    @Environment(VehicleViewModel.self) private var vm
    @Environment(VehicleStore.self) private var store
    @Environment(StoreKitManager.self) private var storeKit

    @State private var showWhySheet = false
    @State private var showExtraPayment = false
    @State private var showYearProjection = false
    @State private var showAmortization = false
    @State private var showShare = false
    @State private var showCompare = false
    @State private var showPaywall = false
    @State private var animate = false

    var body: some View {
        if let result = vm.result {
            content(result: result)
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(TCTheme.bg)
        }
    }

    private func content(result: CalculationResult) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: Verdict banner
                verdictBanner(result: result)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: animate)

                // MARK: DealFit Index gauge
                dealFitCard(result: result)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: animate)

                // MARK: True Monthly Cost + cost stack
                costBreakdownCard(result: result)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3), value: animate)

                // MARK: Why? drivers section
                whySection(result: result)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.35), value: animate)

                // MARK: What to change
                WhatToChangeView(result: result, vehicle: vm.vehicle, currencySymbol: vm.currencySymbol)
                    .padding(16)
                    .tcCard()
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4), value: animate)

                // MARK: Key numbers grid
                keyNumbersGrid(result: result)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.45), value: animate)

                // MARK: Action buttons
                actionButtons(result: result)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.5), value: animate)

                // MARK: Save / Edit
                HStack(spacing: 12) {
                    Button {
                        vm.saveVehicle(to: store)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bookmark.fill")
                                .font(.system(size: 13))
                            Text("Save to Garage")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(TCTheme.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(TCTheme.accent.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(TCTheme.accent.opacity(0.3), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Save to Garage")

                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            vm.showResults = false
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil")
                                .font(.system(size: 13))
                            Text("Edit Deal")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(TCTheme.muted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(TCTheme.panelAlt)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(TCTheme.line, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Edit deal and recalculate")
                }
                .opacity(animate ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.55), value: animate)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .onAppear { animate = true }
        .sheet(isPresented: $showExtraPayment) { ExtraPaymentView() }
        .sheet(isPresented: $showYearProjection) { YearProjectionView() }
        .sheet(isPresented: $showShare) { ShareCardView() }
        .sheet(isPresented: $showCompare) {
            if storeKit.isPro || vm.compareVehicles.isEmpty {
                CompareView()
            } else {
                PaywallView()
            }
        }
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .sheet(isPresented: $showAmortization) {
            AmortizationSheetView(schedule: result.amortizationSchedule, currencySymbol: vm.currencySymbol)
        }
    }

    // MARK: - Verdict Banner

    private func verdictBanner(result: CalculationResult) -> some View {
        let v = result.verdict
        let color = verdictColor(v)

        return HStack(spacing: 14) {
            Image(systemName: v.icon)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 3) {
                Text(v.rawValue.uppercased())
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(color)
                    .tracking(1.5)
                Text(v.summary)
                    .font(.system(size: 14))
                    .foregroundStyle(TCTheme.muted)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(18)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(color.opacity(0.3), lineWidth: 1.5))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Verdict: \(v.rawValue). \(v.summary)")
    }

    // MARK: - DealFit Index

    private func dealFitCard(result: CalculationResult) -> some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("DealFit Index™")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(TCTheme.muted)
                        .tracking(0.5)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(result.dealFitValue))")
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundStyle(verdictColor(result.verdict))
                        Text("/ 100")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(TCTheme.muted)
                    }
                    Text(result.smartScore.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(verdictColor(result.verdict))
                }
                Spacer()

                // Mini gauge arc
                DealFitGauge(value: result.dealFitValue, color: verdictColor(result.verdict))
                    .frame(width: 80, height: 80)
            }

            // Score bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(TCTheme.line)
                        .frame(height: 8)
                    Capsule()
                        .fill(LinearGradient(
                            colors: [TCTheme.bad, TCTheme.warn, TCTheme.good],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geo.size.width * CGFloat(result.dealFitValue / 100), height: 8)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: result.dealFitValue)
                }
            }
            .frame(height: 8)

            if let pct = result.incomePercentage {
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(TCTheme.muted)
                    Text("\(String(format: "%.1f", pct))% of monthly income")
                        .font(.system(size: 12))
                        .foregroundStyle(TCTheme.muted)
                    Spacer()
                    Text(pct < 15 ? "✓ Healthy" : pct < 25 ? "⚠ Moderate" : "⚡ High")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(pct < 15 ? TCTheme.good : pct < 25 ? TCTheme.warn : TCTheme.bad)
                }
            }
        }
        .padding(16)
        .tcCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("DealFit Index \(Int(result.dealFitValue)) out of 100, \(result.smartScore.rawValue)")
    }

    // MARK: - Cost Breakdown

    private func costBreakdownCard(result: CalculationResult) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("True Monthly Cost")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(TCTheme.muted)
                    Text(TCTheme.formatCurrency(result.trueMonthlyCost, symbol: vm.currencySymbol))
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(TCTheme.text)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("~\(TCTheme.formatCurrencyWithCents(result.dailyCost, symbol: vm.currencySymbol))/day")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(TCTheme.muted)
                    Text("incl. depreciation")
                        .font(.system(size: 11))
                        .foregroundStyle(TCTheme.muted.opacity(0.7))
                }
            }

            CostStackChartView.forResult(result, vehicle: vm.vehicle, symbol: vm.currencySymbol)
        }
        .padding(16)
        .tcCard()
    }

    // MARK: - Why Section

    private func whySection(result: CalculationResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(TCTheme.accent2)
                Text("Why This Verdict?")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(TCTheme.text)
            }

            let drivers: [(String, String, Color)] = costDriverInsights(result: result)
            ForEach(drivers, id: \.0) { insight in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(insight.2)
                        .frame(width: 7, height: 7)
                        .padding(.top, 5)
                    Text(insight.1)
                        .font(.system(size: 13))
                        .foregroundStyle(TCTheme.muted)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(16)
        .tcCard()
    }

    private func costDriverInsights(result: CalculationResult) -> [(String, String, Color)] {
        var insights: [(String, String, Color)] = []
        let sym = vm.currencySymbol

        // Loan payment share
        let loanPct = Int(result.monthlyPayment / max(result.trueMonthlyCost, 1) * 100)
        insights.append(("loan",
            "Loan payment is \(loanPct)% of your true cost — \(TCTheme.formatCurrency(result.monthlyPayment, symbol: sym))/mo.",
            TCTheme.accent))

        // Depreciation share
        let depPct = Int(result.monthlyDepreciation / max(result.trueMonthlyCost, 1) * 100)
        insights.append(("depreciation",
            "Depreciation costs you \(TCTheme.formatCurrency(result.monthlyDepreciation, symbol: sym))/mo — \(depPct)% of true cost, even while the car sits.",
            TCTheme.depreciation))

        // Interest load
        let interestRatio = result.totalInterest / max(vm.vehicle.vehiclePrice, 1) * 100
        if interestRatio > 15 {
            insights.append(("interest",
                "Total interest (\(TCTheme.formatCurrency(result.totalInterest, symbol: sym))) is \(Int(interestRatio))% of the vehicle price — a significant financing cost.",
                TCTheme.warn))
        }

        // Income ratio
        if let pct = result.incomePercentage, pct > 20 {
            insights.append(("income",
                "At \(String(format: "%.1f", pct))% of take-home pay, this vehicle consumes more than the recommended 20% threshold.",
                TCTheme.bad))
        }

        return insights
    }

    // MARK: - Key Numbers Grid

    private func keyNumbersGrid(result: CalculationResult) -> some View {
        let sym = vm.currencySymbol
        let items: [(String, String, String)] = [
            ("Loan Payment", TCTheme.formatCurrency(result.monthlyPayment, symbol: sym) + "/mo", "creditcard.fill"),
            ("Total Interest", TCTheme.formatCurrency(result.totalInterest, symbol: sym), "percent"),
            ("5-Year Cost", TCTheme.formatCurrency(result.fiveYearCost, symbol: sym), "calendar"),
            ("Bi-weekly Pmt", TCTheme.formatCurrency(result.biWeeklyPayment, symbol: sym), "arrow.trianglehead.2.clockwise"),
        ]

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(items, id: \.0) { item in
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: item.2)
                            .font(.system(size: 10))
                            .foregroundStyle(TCTheme.muted)
                        Text(item.0)
                            .font(.system(size: 11))
                            .foregroundStyle(TCTheme.muted)
                    }
                    Text(item.1)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(TCTheme.text)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .tcTile()
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(item.0): \(item.1)")
            }
        }
    }

    // MARK: - Action Buttons

    private func actionButtons(result: CalculationResult) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                actionButton(icon: "arrow.up.arrow.down.circle.fill", label: "Compare", color: TCTheme.accent2) {
                    if storeKit.isPro || vm.compareVehicles.isEmpty {
                        showCompare = true
                    } else {
                        showPaywall = true
                    }
                }
                actionButton(icon: "square.and.arrow.up.fill", label: "Share", color: TCTheme.accent) {
                    showShare = true
                }
            }
            HStack(spacing: 10) {
                actionButton(icon: "chart.line.uptrend.xyaxis", label: "5-yr Outlook", color: TCTheme.good) {
                    showYearProjection = true
                }
                actionButton(icon: "list.number", label: "Amortization", color: TCTheme.muted) {
                    showAmortization = true
                }
            }
        }
    }

    private func actionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(TCTheme.text)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundStyle(TCTheme.muted)
            }
            .padding(14)
            .background(TCTheme.panelAlt)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(TCTheme.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private func verdictColor(_ v: VerdictRating) -> Color {
        switch v {
        case .good: return TCTheme.good
        case .caution: return TCTheme.warn
        case .notRecommended: return TCTheme.bad
        }
    }
}

// MARK: - DealFit Gauge (Arc)

struct DealFitGauge: View {
    let value: Double
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(TCTheme.line, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(135))

            Circle()
                .trim(from: 0, to: 0.75 * value / 100)
                .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(135))
                .animation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.3), value: value)

            Text("\(Int(value))")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(color)
        }
    }
}

// MARK: - Amortization Sheet

struct AmortizationSheetView: View {
    @Environment(\.dismiss) private var dismiss
    let schedule: [AmortizationEntry]
    let currencySymbol: String

    var body: some View {
        NavigationStack {
            ZStack {
                TCTheme.bg.ignoresSafeArea()
                List {
                    ForEach(schedule) { entry in
                        HStack {
                            Text("Mo \(entry.month)")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundStyle(TCTheme.muted)
                                .frame(width: 48, alignment: .leading)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("P: \(TCTheme.formatCurrency(entry.principal, symbol: currencySymbol))")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(TCTheme.accent)
                                Text("I: \(TCTheme.formatCurrency(entry.interest, symbol: currencySymbol))")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(TCTheme.depreciation)
                            }
                            Spacer()
                            Text(TCTheme.formatCurrency(entry.remainingBalance, symbol: currencySymbol))
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundStyle(TCTheme.text)
                        }
                        .listRowBackground(TCTheme.panel)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Amortization Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(TCTheme.accent)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    VerdictView()
        .environment(VehicleViewModel())
        .environment(VehicleStore())
        .environment(StoreKitManager())
        .preferredColorScheme(.dark)
}
